import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/book_character_model.dart';
import '../../widget_base/button_base.dart';
import 'character_questionnaire_screen.dart';
import 'character_references_screen.dart';

class AboutCharacterScreen extends StatefulWidget {
  final Character? character;
  final String bookId;
  final String userId;

  const AboutCharacterScreen(
      {super.key, this.character, required this.bookId, required this.userId});

  @override
  State<AboutCharacterScreen> createState() => _AboutCharacterScreenState();
}

class _AboutCharacterScreenState extends State<AboutCharacterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _roleController;
  late final TextEditingController _raceController;
  late final TextEditingController _occupationController;
  late final TextEditingController _appearanceDescriptionController;

  late String _initialName;
  late String _initialAge;
  late String _initialRole;
  late String _initialRace;
  late String _initialOccupation;
  late String _initialAppearanceDescription;
  String? _mainPicUrl;

  bool _hasUnsavedData = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeValues();
    _mainPicUrl = widget.character?.images?.mainImage?.url;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.character?.name ?? '');
    _ageController = TextEditingController(text: widget.character?.age ?? '');
    _roleController = TextEditingController(text: widget.character?.role ?? '');
    _raceController = TextEditingController(text: widget.character?.race ?? '');
    _occupationController =
        TextEditingController(text: widget.character?.occupation ?? '');
    _appearanceDescriptionController = TextEditingController(
        text: widget.character?.appearanceDescription ?? '');
  }

  void _initializeValues() {
    _initialName = _nameController.text;
    _initialAge = _ageController.text;
    _initialRole = _roleController.text;
    _initialRace = _raceController.text;
    _initialOccupation = _occupationController.text;
    _initialAppearanceDescription = _appearanceDescriptionController.text;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _roleController.dispose();
    _raceController.dispose();
    _occupationController.dispose();
    _appearanceDescriptionController.dispose();
  }

  void _checkForChanges() {
    final hasNameChanged = _nameController.text != _initialName;
    final hasAgeChanged = _ageController.text != _initialAge;
    final hasRoleChanged = _roleController.text != _initialRole;
    final hasRaceChanged = _raceController.text != _initialRace;
    final hasOccupationChanged =
        _occupationController.text != _initialOccupation;
    final hasAppearanceDescChanged =
        _appearanceDescriptionController.text != _initialAppearanceDescription;
    setState(() {
      _hasUnsavedData = hasNameChanged ||
          hasAgeChanged ||
          hasRoleChanged ||
          hasRaceChanged ||
          hasOccupationChanged ||
          hasAppearanceDescChanged;
    });
  }

  bool get _isEditing => widget.character != null;

  Future<void> _saveCharacter() async {
    final s = S.of(context);

    final name = _nameController.text.trim();
    final role = _roleController.text.trim();

    if (name.isEmpty || role.isEmpty) {
      _showErrorSnackbar(s.an_error_occurred, s.requiredField);
      return;
    }

    try {
      setState(() => _isSaving = true);

      final updateDate = DateTime.now();
      final lastUpdate = DateFormat('yyyy-MM-dd HH:mm').format(updateDate);

      final characterData = _createCharacterData(name, role, lastUpdate);
      final result = await _saveCharacterToDatabase(characterData);

      if (mounted) {
        _initialName = _nameController.text;
        _initialAge = _ageController.text;
        _initialRole = _roleController.text;
        _initialRace = _raceController.text;
        _initialOccupation = _occupationController.text;
        _initialAppearanceDescription = _appearanceDescriptionController.text;
        _checkForChanges();
        _showSuccessSnackbar(_isEditing ? s.update_success : s.create_success);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AboutCharacterScreen(
              character: result,
              bookId: widget.bookId,
              userId: widget.userId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(s.an_error_occurred, e.toString());
      }
      debugPrint('Character save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _createCharacterData(
      String name, String role, String lastUpdate,
      {String? mainImageUrl}) {
    return {
      'name': name,
      'age': _ageController.text.trim(),
      'role': role,
      'race': _raceController.text.trim(),
      'occupation': _occupationController.text.trim(),
      'appearanceDescription': _appearanceDescriptionController.text.trim(),
      'lastUpdate': lastUpdate,
    };
  }

  Future<Character> _saveCharacterToDatabase(
      Map<String, dynamic> characterData) async {
    DatabaseReference bookRef;
    String bookId = widget.bookId;
    String characterId;

    if (_isEditing) {
      characterId = widget.character!.id;
      bookRef = FirebaseDatabase.instance
          .ref('books/${widget.userId}/$bookId/characters/$characterId');
      await bookRef.update(characterData);
    } else {
      bookRef = FirebaseDatabase.instance
          .ref('books/${widget.userId}/$bookId/characters')
          .push();
      characterId = bookRef.key!;
      await bookRef.set(characterData);
    }

    await _updateBook();

    return Character(
      id: characterId,
      name: characterData['name'],
      age: characterData['age'],
      role: characterData['role'],
      race: characterData['race'],
      occupation: characterData['occupation'],
      appearanceDescription: characterData['appearanceDescription'],
      lastUpdate: characterData['lastUpdate'],
    );
  }

  Future<void> _updateBook() async {
    final updateDate = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final updates = {
      'lastUpdate': formatter.format(updateDate),
    };

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}')
        .update(updates);
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    return PopScope(
      canPop: !_hasUnsavedData,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        if (_hasUnsavedData) {
          final shouldLeave = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(S.of(context).unsaved_data),
                    content: Text(S.of(context).want_to_save),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(S.of(context).no,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary))),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            _saveCharacter();
                          },
                          child: Text(
                            S.of(context).save,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                          )),
                    ],
                  ));
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? character!.name : S.of(context).creating),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Color.lerp(
                const Color(0xFF89B0D9), Colors.white, 0.7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side:
                    const BorderSide(color: Color(0xFF89B0D9))),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_isEditing)
                        _CharacterMainPicWidget(
                          mainPicUrl: _mainPicUrl,
                          bookId: widget.bookId,
                          characterId: character!.id,
                          userId: widget.userId,
                        )
                      else
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      const Spacer(
                        flex: 5,
                      ),
                      Expanded(
                        flex: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildTextField(
                                S.of(context).name, _nameController),
                            const SizedBox(height: 16),
                            _buildTextField(S.of(context).age, _ageController),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(height: 16),
                    Text(S.of(context).add_image_after_character),
                  ],
                  const SizedBox(
                    height: 24,
                  ),
                  _buildTextField(S.of(context).role, _roleController),
                  const SizedBox(height: 16),
                  _buildTextField(S.of(context).race, _raceController),
                  const SizedBox(height: 16),
                  _buildTextField(
                      S.of(context).occupation, _occupationController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(S.of(context).appearanceDescription,
                      _appearanceDescriptionController,
                      maxLines: 5),
                  const SizedBox(height: 24),
                  if(_isEditing) ...[
                    Card(
                      elevation: 0,
                      color: Color.lerp(
                          const Color(0xFFA5C6EA), Colors.white,
                          0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFA5C6EA),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets
                            .symmetric(
                          horizontal: 16,
                        ),
                        title: Text(
                          S.of(context).questionnaire,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            CharacterQuestionnaireScreen(bookId: widget.bookId, userId: widget.userId, character: widget.character!))),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Card(
                      elevation: 0,
                      color: Color.lerp(
                          const Color(0xFFA5C6EA), Colors.white,
                          0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFA5C6EA),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets
                            .symmetric(
                          horizontal: 16,
                        ),
                        title: Text(
                          S.of(context).references,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          CharacterReferencesScreen(bookId: widget.bookId, userId: widget.userId, character: widget.character!))),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24,),
                  ],

                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveCharacter,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF89B0D9)),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      ),
                    ),
                    child: Text(
                      S.of(context).save,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).colorScheme.tertiary,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) => _checkForChanges(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 0.5,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1.5,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      maxLines: maxLines,
    );
  }
}

class _CharacterMainPicWidget extends StatefulWidget {
  String? mainPicUrl;
  String bookId;
  String userId;
  String characterId;

  _CharacterMainPicWidget(
      {super.key,
      required this.mainPicUrl,
      required this.userId,
      required this.bookId,
      required this.characterId});

  @override
  State<_CharacterMainPicWidget> createState() =>
      _CharacterMainPicWidgetState();
}

class _CharacterMainPicWidgetState extends State<_CharacterMainPicWidget> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCharacterImage();
  }

  Future<void> _loadCharacterImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/images/mainImage/url');
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        setState(() {
          widget.mainPicUrl = snapshot.value as String;
        });
      } else {
        setState(() {
          widget.mainPicUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        widget.mainPicUrl = null;
      });
      debugPrint('Error loading character image: $e');
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).don_t_have_access)),
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
    try {
      setState(() {
        _isLoadingImage = true;
      });

      String path =
          'characterImages/${widget.bookId}/${widget.characterId}/mainImage/${widget.characterId}.jpg';
      final ref = _storage.ref().child(path);
      await ref.putData(imageData);

      final url = await ref.getDownloadURL();

      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/images/mainImage');
      await dbRef.set({
        'url': url,
        'addedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        widget.mainPicUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).an_error_occurred)),
      );
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: _isLoadingImage
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.tertiary))
              : widget.mainPicUrl != null
                  ? Image.network(widget.mainPicUrl!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      size: 80,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
        ),
      ),
    );
  }
}
