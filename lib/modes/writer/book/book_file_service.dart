import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';

class BookFileService {
  final String userId;
  final String bookId;
  final BuildContext context;

  final FirebaseStorage storage = FirebaseStorage.instance;
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  BookFileService({required this.userId, required this.bookId, required this.context});

  String get storagePath => 'bookFiles/$userId/$bookId';

  Future<String?> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'epub', 'fb2'],
      );
      if(result == null || result.files.isEmpty) return null;
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileExtension = fileName.split('.').last.toLowerCase();
      const allowedExtensions = {'pdf', 'doc', 'docx', 'txt', 'epub', 'fb2'};
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception(S.of(context).invalid_file_format);
      }
      final ref = storage.ref('$storagePath/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    }
    catch(e){
      debugPrint('error - $e');
      rethrow;
    }
  }

  Future<void> openFile(String fileName) async {
    try {
      final ref = storage.ref('$storagePath/$fileName');
      final url = await ref.getDownloadURL();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      if(await file.exists()) {
        await OpenFile.open(file.path);
        return;
      }

      await ref.writeToFile(file);
      await OpenFile.open(file.path);
    }
    catch(e) {
      debugPrint('erororor - $e');
      rethrow;
    }
  }

  Future<File> downloadToDownloads({
    required String userId,
    required String bookId,
    required String fileName,
  }) async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final sdkInt = androidInfo.version.sdkInt;
        PermissionStatus status;

        if (sdkInt >= 30) {
          status = await Permission.manageExternalStorage.request();
        } else {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            AppSettings.openAppSettings();
            throw Exception('Разрешение навсегда запрещено. Включи его в настройках.');
          }
          throw Exception('Доступ к хранилищу не предоставлен.');
        }
      }

      final Directory downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        throw Exception(S.of(context).folder_not_found);
      }

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);

      final ref = FirebaseStorage.instance
          .ref('bookFiles/$userId/$bookId/$fileName');

      final task = ref.writeToFile(file);
      await task.whenComplete(() {});

      if (!await file.exists()) {
        throw Exception(S.of(context).file_was_not_saved);
      }

      return file;
    } catch (e) {
      throw Exception('${S.of(context).an_error_occurred}: ${e.toString()}');
    }
  }

  Future<void> deleteFile(String fileName) async {
    try{
      final ref = storage.ref('$storagePath/$fileName');
      final url = await ref.getDownloadURL();
      await ref.delete();
      await cacheManager.removeFile(url);
    }
    catch(e) {
      debugPrint('errrror - $e');
      rethrow;
    }
  }

  Future<List<String>> filesList() async {
    try{
      final ref = storage.ref(storagePath);
      final result = await ref.listAll();
      return result.items.map((item) => item.name).toList();
    }
    catch(e) {
      debugPrint('errorr - $e');
      return [];
    }
  }
}