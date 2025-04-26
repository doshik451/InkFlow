import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkflow/modes/writer/book/book_file_service.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../generated/l10n.dart';
import '../../../models/book_writer_model.dart';
import 'main_book_base.dart';

class AboutBookPage extends StatefulWidget {
  final Book? book;
  final String authorId;

  const AboutBookPage({
    super.key,
    this.book,
    required this.authorId,
  });

  @override
  State<AboutBookPage> createState() => _AboutBookPageState();
}

class _AboutBookPageState extends State<AboutBookPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorNameController;
  late final TextEditingController _settingController;
  late final TextEditingController _genreController;
  late final TextEditingController _themeController;
  late final TextEditingController _messageController;
  late final TextEditingController _descriptionController;
  late Status _status;
  late List<Status> _statuses;
  List<String> _files = [];
  late BookFileService _bookFileService;
  bool _isLoadingFiles = false;
  bool _isUploading = false;
  File? _localCoverImage;
  bool _coverLoadError = false;
  bool _isSaving = false;
  bool _isDownloading = false;
  String? _coverUrl;
  bool _hasUnsavedData = false;

  late String _initialTitle;
  late String _initialDescription;
  late Status _initialStatus;
  late String? _initialCoverUrl;
  late String _initialSetting;
  late String _initialGenre;
  late String _initialTheme;
  late String _initialMessage;
  late String _initialAuthorName;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _coverUrl = widget.book?.coverUrl;
    _status = widget.book?.status ?? Status.draft;
    _statuses = Status.values;

    _initialTitle = _titleController.text;
    _initialAuthorName = _authorNameController.text;
    _initialDescription = _descriptionController.text;
    _initialStatus = _status;
    _initialCoverUrl = _coverUrl;
    _initialSetting = _settingController.text;
    _initialGenre = _genreController.text;
    _initialTheme = _themeController.text;
    _initialMessage = _messageController.text;

    if (_isEditing) {
      _bookFileService =
          BookFileService(userId: widget.authorId, bookId: widget.book!.id, context: context);
      _loadBookFiles();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorNameController = TextEditingController(
      text: widget.book?.authorName ??
          FirebaseAuth.instance.currentUser?.displayName,
    );
    _settingController =
        TextEditingController(text: widget.book?.setting ?? '');
    _themeController = TextEditingController(text: widget.book?.theme ?? '');
    _genreController = TextEditingController(text: widget.book?.genre ?? '');
    _messageController =
        TextEditingController(text: widget.book?.message ?? '');
    _descriptionController = TextEditingController(
      text: widget.book?.description ?? '',
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _titleController.dispose();
    _authorNameController.dispose();
    _settingController.dispose();
    _themeController.dispose();
    _genreController.dispose();
    _messageController.dispose();
    _descriptionController.dispose();
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasAuthorNameChanged =
        _authorNameController.text != _initialAuthorName;
    final hasDescriptionChanged =
        _descriptionController.text != _initialDescription;
    final hasStatusChanged = _status != _initialStatus;
    final hasCoverUrlChanged = _coverUrl != _initialCoverUrl;
    final hasSettingChanged = _settingController.text != _initialSetting;
    final hasThemeChanged = _themeController.text != _initialTheme;
    final hasGenreChanged = _genreController.text != _initialGenre;
    final hasMessageChanged = _messageController.text != _initialMessage;

    setState(() {
      _hasUnsavedData = hasTitleChanged ||
          hasDescriptionChanged ||
          hasStatusChanged ||
          hasAuthorNameChanged ||
          hasCoverUrlChanged ||
          hasSettingChanged ||
          hasThemeChanged ||
          hasMessageChanged ||
          hasGenreChanged;
    });
  }

  Future<File?> _compressBookCover(File originalImage) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        originalImage.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 1200,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _uploadCover() async {
    if (_localCoverImage == null) return;

    setState(() => _isUploading = true);

    try {
      final compressedFile = await _compressBookCover(_localCoverImage!);
      final fileToUpload = compressedFile ?? _localCoverImage!;

      final bookId = widget.book?.id ??
          FirebaseDatabase.instance.ref('books/${widget.authorId}').push().key!;
      final storageRef = FirebaseStorage.instance.ref('bookCovers/$bookId.jpg');

      await storageRef.putFile(fileToUpload);
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _coverUrl = downloadUrl;
        _initialCoverUrl = downloadUrl;
      });
      _checkForChanges();
    } catch (e) {
      setState(() => _coverLoadError = true);
      _showErrorSnackbar(S.of(context).an_error_occurred, e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _localCoverImage = File(pickedFile.path);
          _coverLoadError = false;
        });
        await _uploadCover();
      }
    } catch (e) {
      setState(() => _coverLoadError = true);
      _showErrorSnackbar(S.of(context).an_error_occurred, e.toString());
    }
  }

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  Future<void> _saveBook() async {
    final s = S.of(context);

    final title = _titleController.text.trim();
    final author = _authorNameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || author.isEmpty || desc.isEmpty) {
      _showErrorSnackbar(s.an_error_occurred, s.requiredField);
      return;
    }

    try {
      setState(() => _isSaving = true);

      final updateDate = DateTime.now();
      final lastUpdate = DateFormat('yyyy-MM-dd HH:mm').format(updateDate);

      final bookData = _createBookData(title, author, lastUpdate);
      final result = await _saveBookToDatabase(bookData);

      if (mounted) {
        _initialTitle = _titleController.text;
        _initialAuthorName = _authorNameController.text;
        _initialDescription = _descriptionController.text;
        _initialStatus = _status;
        _initialCoverUrl = _coverUrl;
        _initialSetting = _settingController.text;
        _initialTheme = _themeController.text;
        _initialMessage = _messageController.text;
        _initialGenre = _genreController.text;
        _checkForChanges();
        _showSuccessSnackbar(_isEditing ? s.update_success : s.create_success);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainBookBase(book: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(s.an_error_occurred, e.toString());
      }
      debugPrint('Book save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _createBookData(
      String title, String author, String lastUpdate) {
    return {
      'title': title,
      'authorName': author,
      'setting': _settingController.text.trim(),
      'theme': _themeController.text.trim(),
      'message': _messageController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': _status.name,
      'lastUpdate': lastUpdate,
      'genre': _genreController.text.trim(),
      'coverUrl': _coverUrl,
      'files': _files,
      'authorId': widget.authorId,
    };
  }

  Future<Book> _saveBookToDatabase(Map<String, dynamic> bookData) async {
    DatabaseReference bookRef;
    String bookId;

    if (_isEditing) {
      bookId = widget.book!.id;
      bookRef =
          FirebaseDatabase.instance.ref('books/${widget.authorId}/$bookId');
      await bookRef.update(bookData);
    } else {
      bookRef =
          FirebaseDatabase.instance.ref('books/${widget.authorId}').push();
      bookId = bookRef.key!;
      await bookRef.set(bookData);
    }

    return Book(
      id: bookId,
      authorId: widget.authorId,
      authorName: bookData['authorName'],
      title: bookData['title'],
      setting: bookData['setting'],
      genre: bookData['genre'],
      description: bookData['description'],
      status: _status,
      lastUpdate: bookData['lastUpdate'],
      message: bookData['message'],
      theme: bookData['theme'],
      coverUrl: _coverUrl,
      files: _files,
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCoverImage() {
    if (_coverLoadError) return const ErrorPlaceholderWidget();

    if (_coverUrl != null && _coverUrl!.isNotEmpty ||
        _localCoverImage != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _status.color,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: _coverUrl != null
              ? Image.network(
                  _coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ErrorPlaceholderWidget(),
                )
              : Image.file(
                  _localCoverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ErrorPlaceholderWidget(),
                ),
        ),
      );
    }
    return _buildAddCoverPlaceholder();
  }

  Widget _buildAddCoverPlaceholder() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).add_image,
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }

  Future<void> _loadBookFiles() async {
    if (!_isEditing) return;
    setState(() {
      _isLoadingFiles = true;
    });
    try {
      _files = await _bookFileService.filesList();
    } catch (e) {
      debugPrint('error - $e');
    } finally {
      setState(() {
        _isLoadingFiles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
                            _saveBook();
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
          title: Text(_isEditing ? s.editing : s.creating),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Color.lerp(_status.color, Colors.white, 0.7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _status.color)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCoverSection(),
                  const SizedBox(height: 24),
                  _buildTextField(s.title, _titleController),
                  const SizedBox(height: 16),
                  _buildTextField(s.author, _authorNameController),
                  const SizedBox(height: 16),
                  _buildTextField(s.setting, _settingController),
                  const SizedBox(height: 16),
                  _buildTextField(s.genre, _genreController),
                  const SizedBox(height: 16),
                  _buildTextField(s.theme, _themeController),
                  const SizedBox(height: 16),
                  _buildTextField(s.message, _messageController, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(context),
                  const SizedBox(height: 16),
                  _buildTextField(s.description, _descriptionController,
                      maxLines: 5),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildFilesSection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveBook,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(_status.color),
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

  Future<void> _downloadFile(String fileName) async {
    setState(() => _isDownloading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final bookId = widget.book!.id;

      final file = await _bookFileService.downloadToDownloads(
        userId: userId,
        bookId: bookId,
        fileName: fileName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📥 ${S.of(context).file_saved}: ${file.path}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${S.of(context).an_error_occurred}'),
            duration: const Duration(seconds: 4),
          ));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Widget _buildCoverSection() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickImage,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _shouldShowPlaceholder()
              ? Color.lerp(_status.color, Colors.white, 0.4)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isUploading
            ? _buildUploadProgress()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      if (_coverUrl != null && !_coverLoadError)
                        _buildCoverImage(),
                      if (_shouldShowPlaceholder()) _buildAddCoverPlaceholder(),
                      if (_coverLoadError) const ErrorPlaceholderWidget(),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFA5C6EA),
          ),
        ],
      ),
    );
  }

  bool _shouldShowPlaceholder() {
    return (widget.book?.coverUrl == null || widget.book!.coverUrl!.isEmpty) &&
        _localCoverImage == null;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      cursorColor: _status.color,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) => _checkForChanges(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 0.5, color: _status.color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1.5, color: _status.color),
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonFormField<Status>(
      value: _status,
      decoration: InputDecoration(
        labelText: S.of(context).status,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _status.color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _status.color, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownColor: Color.lerp(_status.color, Colors.white, 0.7),
      style: const TextStyle(color: Colors.black),
      items: _statuses.map((status) {
        final isSelected = status == _status;
        return DropdownMenuItem(
          value: status,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _status.color : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            child: Text(
              status.title(context),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _status = value;
            _checkForChanges();
          });
        }
      },
    );
  }

  Widget _buildFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context).add_book_file,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8,),
            IconButton(
              onPressed: () async {
                setState(() {
                  _isDownloading = true;
                });
                final downloadUrl = await _bookFileService.uploadFile();
                if (downloadUrl != null) await _loadBookFiles();
                if(mounted) {
                  setState(() {
                    _isDownloading = false;
                  });
                }
              },
              icon: _isDownloading ? const CircularProgressIndicator(color: Color(0xFF89B0D9),) : const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: _status.color,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        if (_isLoadingFiles)
          CircularProgressIndicator(
            color: _status.color,
          )
        else
          ..._files.map((file) => ListTile(
                title: Text(file),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _bookFileService.openSavedFile(file),
                      icon: const Icon(Icons.remove_red_eye),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed:
                          _isDownloading ? () => const CircularProgressIndicator(color: Color(0xFF89B0D9),) : () => _downloadFile(file),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _bookFileService.deleteFile(file);
                        await _loadBookFiles();
                      },
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}

class ErrorPlaceholderWidget extends StatelessWidget {
  const ErrorPlaceholderWidget({super.key});

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            S.of(context).an_error_occurred,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
