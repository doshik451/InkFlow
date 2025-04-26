import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_selector/file_selector.dart';
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
      final typeGroups = [
        XTypeGroup(
          label: S.of(context).add_book_file,
          extensions: ['pdf', 'doc', 'docx', 'txt', 'epub', 'fb2'],
        ),
      ];

      final XFile? file = await openFile(acceptedTypeGroups: typeGroups);

      if (file == null) {
        return null;
      }

      final fileName = file.name;
      final path = file.path;
      final ref = storage.ref('$storagePath/$fileName');

      await ref.putFile(File(path));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('error - $e');
      rethrow;
    }
  }

  Future<void> openSavedFile(String fileName) async {
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
      await OpenFile.open(file.path);
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