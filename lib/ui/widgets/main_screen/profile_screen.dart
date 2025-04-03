import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkflow/utils/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../bloc/language/locale_cubit.dart';
import '../../../bloc/theme/theme_cubit.dart';
import '../../../generated/l10n.dart';
import '../auth_screen/login_screen.dart';
import '../widget_base/button_base.dart';
import '../widget_base/short_data_field_base.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDark;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 50, automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const _UserDataWidget(),
              const SizedBox(height: 120,),
              ButtonBase(text: S.current.dark_theme, value: isDark,
                onPressed: () => context.read<ThemeCubit>().setTheme(isDark ? Brightness.light : Brightness.dark),),
              const SizedBox(height: 16,),
              ButtonBase(text: S.current.change_lang, onPressed: () {
                context.read<LocaleCubit>().toggleLocale();
              },),
              const SizedBox(height: 16,),
              ButtonBase(text: S.current.change_mode, onPressed: () {},),
              const SizedBox(height: 16,),
              ButtonBase(text: S.current.about_app, onPressed: () {
                Navigator.pushNamed(context, Routes.aboutApp);
              },),
              const SizedBox(height: 16,),
              ButtonBase(text: S.current.logout, onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                      (Route<dynamic> route) => false,
                );
              }, icon: Icons.logout_rounded,),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserDataWidget extends StatefulWidget {
  const _UserDataWidget({super.key});

  @override
  State<_UserDataWidget> createState() => _UserDataWidgetState();
}

class _UserDataWidgetState extends State<_UserDataWidget> {
  String? imageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }

  Future<void> _loadUserImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      String path = 'profileImages/${user.uid}.jpg';
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      setState(() {
        imageUrl = null;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.don_t_have_access)),
      );
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File imageFile = File(pickedFile.path);
    Uint8List? compressedImage = await _compressImage(imageFile);
    if (compressedImage == null) return;
    await _uploadImageToFirebase(compressedImage);
  }

  Future<Uint8List?> _compressImage(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  Future<void> _uploadImageToFirebase(Uint8List imageData) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      String path = 'profileImages/${user.uid}.jpg';
      final ref = _storage.ref().child(path);
      await ref.putData(imageData);
      _loadUserImage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.an_error_occurred)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Row(
      children: [
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 3),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.tertiary,),
            ),
          ),
        ),
        const Spacer(flex: 5,),
        Expanded(
          flex: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShortDataField(label: S.current.username, value: user?.displayName ?? S.current.unknown, readOnly: true,),
              const SizedBox(height: 10,),
              ShortDataField(label: S.current.email, value: user?.email ?? S.current.unknown, readOnly: true,),
            ],
          ),
        ),
      ],
    );
  }
}