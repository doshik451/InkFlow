import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../generated/l10n.dart';
import '../../../models/book_in_plan_model.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../writer/book/book_file_service.dart';
import 'package:collection/collection.dart';

class BookInPlanScreen extends StatefulWidget {
  final BookInPlan? bookInPlan;
  final String userId;

  const BookInPlanScreen({
    super.key,
    this.bookInPlan,
    required this.userId,
  });

  @override
  State<BookInPlanScreen> createState() => _BookInPlanScreenState();
}

class _BookInPlanScreenState extends State<BookInPlanScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorNameController;
  late final TextEditingController _genreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  late BookInPlanPriority _priority;
  late List<BookInPlanPriority> _priorities;
  List<String> _files = [];
  List<String> _links = [];
  late BookFileService _bookFileService;
  bool _isLoadingFiles = false;
  bool _isSaving = false;
  bool _isDownloading = false;
  bool _hasUnsavedData = false;

  late String _initialTitle;
  late String _initialDescription;
  late String _initialGenre;
  late BookInPlanPriority _initialPriority;
  late String _initialAuthorName;
  late List<String> _initialLinks;

  bool get _isEditing => widget.bookInPlan != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _priority = widget.bookInPlan?.priority ?? BookInPlanPriority.notDefined;
    _priorities = BookInPlanPriority.values;
    _links = widget.bookInPlan?.links ?? [];

    _initialTitle = _titleController.text;
    _initialAuthorName = _authorNameController.text;
    _initialDescription = _descriptionController.text;
    _initialPriority = _priority;
    _initialGenre = _genreController.text;
    _initialLinks = List.from(_links);

    if (_isEditing) {
      _bookFileService =
          BookFileService(userId: widget.userId, bookId: widget.bookInPlan!.id, context: context, pathPart: 'booksInPlan');
      _loadBookFiles();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.bookInPlan?.title ?? '');
    _authorNameController = TextEditingController(text: widget.bookInPlan?.authorName ?? '');
    _genreController = TextEditingController(text: widget.bookInPlan?.genreNTags ?? '');
    _descriptionController = TextEditingController(text: widget.bookInPlan?.description ?? '');
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _titleController.dispose();
    _authorNameController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasAuthorNameChanged =
        _authorNameController.text != _initialAuthorName;
    final hasDescriptionChanged =
        _descriptionController.text != _initialDescription;
    final hasGenreChanged = _genreController.text != _initialGenre;
    final hasPriorityChanged = _priority != _initialPriority;
    final hasLinksChanged = !const DeepCollectionEquality().equals(_links, _initialLinks);

    setState(() {
      _hasUnsavedData = hasTitleChanged ||
          hasDescriptionChanged ||
          hasPriorityChanged ||
          hasAuthorNameChanged ||
          hasGenreChanged || hasLinksChanged;
    });
  }

  void _addLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).an_error_occurred)),
      );
      return;
    }

    setState(() {
      _links.add(link);
      _linkController.clear();
      _checkForChanges();
    });

    FocusScope.of(context).unfocus();
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).an_error_occurred)),
      );
    }
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

  Future<void> _saveBook() async {
    final s = S.of(context);

    final title = _titleController.text.trim();
    final author = _authorNameController.text.trim();

    if (title.isEmpty || author.isEmpty) {
      _showErrorSnackbar(s.an_error_occurred, s.requiredField);
      return;
    }

    try {
      setState(() => _isSaving = true);

      final updateDate = DateTime.now();
      final lastUpdate = DateFormat('yyyy-MM-dd HH:mm').format(updateDate);

      final bookData = _createBookData(title, author, lastUpdate);
      await _saveBookToDatabase(bookData);

      if (mounted) {
        _initialTitle = _titleController.text;
        _initialAuthorName = _authorNameController.text;
        _initialDescription = _descriptionController.text;
        _initialPriority = _priority;
        _initialGenre = _genreController.text;
        _initialLinks = List.from(_links);
        _checkForChanges();

        Navigator.pop(context);
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

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  Map<String, dynamic> _createBookData(
      String title, String author, String lastUpdate) {
    return {
      'title': title,
      'authorName': author,
      'description': _descriptionController.text.trim(),
      'priority': _priority.name,
      'lastUpdate': lastUpdate,
      'genreNTags': _genreController.text.trim(),
      'files': _files,
      'links': _links,
      'userId': widget.userId,
    };
  }

  Future<BookInPlan> _saveBookToDatabase(Map<String, dynamic> bookData) async {
    DatabaseReference bookRef;
    String bookId;

    if (_isEditing) {
      bookId = widget.bookInPlan!.id;
      bookRef =
          FirebaseDatabase.instance.ref('planBooks/${widget.userId}/$bookId');
      await bookRef.update(bookData);
    } else {
      bookRef =
          FirebaseDatabase.instance.ref('planBooks/${widget.userId}').push();
      bookId = bookRef.key!;
      await bookRef.set(bookData);
    }

    return BookInPlan(
      id: bookId,
      userId: widget.userId,
      authorName: bookData['authorName'],
      title: bookData['title'],
      genreNTags: bookData['genreNTags'],
      description: bookData['description'],
      priority: _priority,
      lastUpdate: bookData['lastUpdate'],
      files: _files,
      links: _links
    );
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
                        Navigator.of(context).pop(false);
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
          title: Text(_isEditing ? widget.bookInPlan!.title : s.creating),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Color.lerp(_priority.color, Colors.white, 0.7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: _priority.color)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildTextField(s.workName, _titleController),
                    const SizedBox(height: 16),
                    _buildTextField(s.author, _authorNameController),
                    const SizedBox(height: 16),
                    _buildTextField(s.genreNTags, _genreController, maxLines: 2),
                    const SizedBox(height: 16),
                    _buildTextField(s.description, _descriptionController,
                        maxLines: 5),
                    const SizedBox(height: 16),
                    _buildPriorityDropdown(context),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildLinksSection(),
                    const SizedBox(height: 16),
                    _buildFilesSection(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveBook,
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(_priority.color),
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
      ),
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).links,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _linkController,
                cursorColor: _priority.color,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: S.of(context).add_link,
                  labelStyle: const TextStyle(color: Colors.black),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width: 0.5, color: _priority.color),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width: 1.5, color: _priority.color),
                  ),
                ),
                onSubmitted: (_) => _addLink(),
              ),
            ),
            IconButton(
              onPressed: _addLink,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: _priority.color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._links.asMap().entries.map((entry) => ListTile(
          title: Text(
            entry.value,
            style: const TextStyle(color: Colors.blue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () async {
              final shouldDelete = await confirmDelete(context);
              if (shouldDelete ?? false) {
                _removeLink(entry.key);
              }
            },
          ),
          onTap: () => _openLink(entry.value),
        )),
      ],
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    return DropdownButtonFormField<BookInPlanPriority>(
      value: _priority,
      decoration: InputDecoration(
        labelText: S.of(context).priority,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _priority.color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _priority.color, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownColor: Color.lerp(_priority.color, Colors.white, 0.7),
      style: const TextStyle(color: Colors.black),
      items: _priorities.map((status) {
        final isSelected = status == _priority;
        return DropdownMenuItem(
          value: status,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _priority.color : Colors.transparent,
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
            _priority = value;
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
                backgroundColor: _priority.color,
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
            color: _priority.color,
          )
        else
          ..._files.map((file) => ListTile(
            title: Text(file, style: const TextStyle(color: Colors.black),),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _bookFileService.openSavedFile(file),
                  icon: const Icon(Icons.remove_red_eye, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.black),
                  onPressed:
                  _isDownloading ? () => const CircularProgressIndicator(color: Color(0xFF89B0D9),) : () => _downloadFile(file),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () async {
                    final shouldDelete = await confirmDelete(context);
                    if (shouldDelete ?? false) {
                      await _bookFileService.deleteFile(file);
                      await _loadBookFiles();
                    }
                  },
                ),
              ],
            ),
          )),
      ],
    );
  }

  Future<void> _downloadFile(String fileName) async {
    setState(() => _isDownloading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final bookId = widget.bookInPlan!.id;

      final file = await _bookFileService.downloadToDownloads(
          userId: userId,
          bookId: bookId,
          fileName: fileName,
          pathPart: 'booksInPlan'
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

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      cursorColor: _priority.color,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) => _checkForChanges(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 0.5, color: _priority.color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1.5, color: _priority.color),
        ),
      ),
      maxLines: maxLines,
    );
  }
}
