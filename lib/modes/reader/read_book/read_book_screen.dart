import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:inkflow/modes/reader/read_book/moments_screen.dart';
import 'package:inkflow/modes/reader/read_book/review_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../writer/book/book_file_service.dart';
import 'package:collection/collection.dart';

class ReadBookScreen extends StatefulWidget {
  FinishedBook? book;
  final BookCategory bookCategory;
  final String userId;

  ReadBookScreen(
      {super.key, this.book, required this.userId, required this.bookCategory});

  @override
  _ReadBookScreenState createState() => _ReadBookScreenState();
}

class _ReadBookScreenState extends State<ReadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late String _startDate;
  late String _endDate;
  late BookCategory _selectedCategory;
  List<String> _files = [];
  List<String> _links = [];
  late BookFileService _bookFileService;
  late Future<List<BookCategory>> _categoriesFuture;
  late FinishedBook? _finishedBook;
  bool _isDownloading = false;
  bool _isLoadingFiles = false;
  bool _hasUnsavedData = false;

  late String _initialTitle;
  late String _initialAuthorName;
  late String _initialDescription;
  late String _initialStartDate;
  late String _initialEndDate;
  late String _initialCategoryId;
  late List<String> _initialLinks;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();

    _finishedBook = widget.book;
    _titleController = TextEditingController(text: _finishedBook?.title ?? '');
    _authorController = TextEditingController(text: _finishedBook?.author ?? '');
    _descriptionController =
        TextEditingController(text: _finishedBook?.description ?? '');

    _linkController = TextEditingController();

    _startDate = _finishedBook?.startDate ?? '';
    _endDate = _finishedBook?.endDate ?? '';
    _links = _finishedBook?.links ?? [];

    _selectedCategory = widget.bookCategory;
    _categoriesFuture = _loadCategories();

    _initialTitle = _titleController.text;
    _initialAuthorName = _authorController.text;
    _initialDescription = _descriptionController.text;
    _initialStartDate = _startDate;
    _initialEndDate = _endDate;
    _initialCategoryId = _selectedCategory.id;
    _initialLinks = List.from(_links);

    if (_isEditing) {
      _bookFileService = BookFileService(
          userId: widget.userId,
          bookId: _finishedBook!.id,
          context: context,
          pathPart: 'readBooks');
      _loadBookFiles();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasDescriptionChanged =
        _descriptionController.text != _initialDescription;
    final hasAuthorNameChanged = _authorController.text != _initialAuthorName;
    final hasStartDateChanged = _startDate != _initialStartDate;
    final hasEndDateChanged = _endDate != _initialEndDate;
    final hasCategoryChanged = _selectedCategory.id != _initialCategoryId;
    final hasLinksChanged =
        !const DeepCollectionEquality().equals(_links, _initialLinks);

    setState(() {
      _hasUnsavedData = hasTitleChanged ||
          hasDescriptionChanged ||
          hasAuthorNameChanged ||
          hasStartDateChanged ||
          hasEndDateChanged ||
          hasCategoryChanged ||
          hasLinksChanged;
    });
  }

  Future<List<BookCategory>> _loadCategories() async {
    final defaultSnap =
        await FirebaseDatabase.instance.ref('defaultCategories').get();
    final customSnap = await FirebaseDatabase.instance
        .ref('customCategories/${widget.userId}')
        .get();

    final defaultCategories = <BookCategory>[];
    final customCategories = <BookCategory>[];

    if (defaultSnap.exists) {
      for (var child in defaultSnap.children) {
        defaultCategories.add(BookCategory.fromMap(
            child.key!, Map<String, dynamic>.from(child.value as Map)));
      }
    }

    if (customSnap.exists) {
      for (var child in customSnap.children) {
        customCategories.add(BookCategory.fromMap(
            child.key!, Map<String, dynamic>.from(child.value as Map)));
      }
    }

    return [...defaultCategories, ...customCategories];
  }

  Future<void> _saveBook() async {
    final title = _titleController.text.trim();
    final authorName = _authorController.text.trim();

    if (title.isEmpty || authorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).requiredField,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    String bookId;
    try {
      if (_finishedBook != null) {
        await _databaseReference
            .child('finishedBooks/${widget.userId}/${_finishedBook!.id}')
            .update({
          'title': title,
          'author': authorName,
          'description': _descriptionController.text.trim(),
          'startDate': _startDate,
          'endDate': _endDate,
          'categoryId': _selectedCategory.id,
          'files': _files,
          'links': _links,
        });
        bookId = _finishedBook!.id;
      } else {
        final ref =
            _databaseReference.child('finishedBooks/${widget.userId}').push();
        await ref.set({
          'userId': widget.userId,
          'title': title,
          'author': authorName,
          'description': _descriptionController.text.trim(),
          'startDate': _startDate,
          'endDate': _endDate,
          'categoryId': _selectedCategory.id,
          'files': _files,
          'links': _links,
        });
        bookId = ref.key!;
      }

      if (mounted) {
        setState(() {
          _initialTitle = title;
          _initialDescription = _descriptionController.text.trim();
          _initialAuthorName = authorName;
          _initialStartDate = _startDate;
          _initialEndDate = _endDate;
          _initialCategoryId = _selectedCategory.id;
          _initialLinks = List.from(_links);
          _checkForChanges();
        });

        _showSuccessSnackbar(
          _isEditing
              ? S.of(context).update_success
              : S.of(context).create_success,
        );

        final updatedBook = FinishedBook.fromMap(bookId, {
          'title': title,
          'author': authorName,
          'description': _descriptionController.text.trim(),
          'startDate': _startDate,
          'endDate': _endDate,
          'categoryId': _selectedCategory.id,
          'files': _files,
          'links': _links,
        });

        Navigator.pop(context, {
          'reload': true,
          'book': updatedBook,
          'category': _selectedCategory,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.current.an_error_occurred}: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '...';
    final date = DateTime.tryParse(dateString);
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : '...';
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    S.of(context).no,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    S.of(context).save,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ],
            ),
          );
          if (shouldLeave == true && mounted) await _saveBook();
        } else {
          Navigator.pop(context, {
            'reload': true
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_finishedBook == null
              ? S.of(context).creating
              : _finishedBook!.title),
          centerTitle: true,
        ),
        body: FutureBuilder<List<BookCategory>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(S.of(context).an_error_occurred));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(S.of(context).no_categories));
            }

            final categories = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        color: Color.lerp(
                            Color(int.parse(_selectedCategory.colorCode)),
                            Colors.white,
                            0.7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Color(
                                    int.parse(_selectedCategory.colorCode)))),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              _buildTextField(
                                  S.of(context).workName, _titleController),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  S.of(context).author, _authorController),
                              const SizedBox(height: 16),
                              _buildTextField(S.of(context).description,
                                  _descriptionController,
                                  maxLines: 5),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      S.of(context).reading_dates,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final date =
                                              await _showCustomDatePicker(
                                            context: context,
                                            initialDate: _startDate.isEmpty
                                                ? DateTime.now()
                                                : DateTime.parse(_startDate),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (date != null && mounted) {
                                            setState(() {
                                              _startDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(date);
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          child: Text(
                                            _startDate.isEmpty
                                                ? '...'
                                                : _formatDate(_startDate),
                                            style: TextStyle(
                                              fontSize:
                                                  _startDate.isEmpty ? 20 : 16,
                                              color: _startDate.isEmpty
                                                  ? Colors.grey
                                                  : Colors.black,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text('—',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      GestureDetector(
                                        onTap: () async {
                                          if (_startDate.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  S.of(context).select_start_date,
                                                  style: const TextStyle(color: Colors.black),
                                                ),
                                                backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final initial = _endDate.isEmpty
                                              ? DateTime.tryParse(_startDate)
                                              : DateTime.tryParse(_endDate);

                                          final date =
                                              await _showCustomDatePicker(
                                            context: context,
                                            initialDate:
                                                initial ?? DateTime.now(),
                                            firstDate:
                                                DateTime.tryParse(_startDate)!,
                                            lastDate: DateTime(2101),
                                          );

                                          if (date != null && mounted) {
                                            setState(() {
                                              _endDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(date);
                                              _checkForChanges();
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          child: Text(
                                            _endDate.isEmpty
                                                ? '...'
                                                : _formatDate(_endDate),
                                            style: TextStyle(
                                                fontSize:
                                                    _endDate.isEmpty ? 20 : 16,
                                                color: Colors.black,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.black,
                                                decorationThickness: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildLinksSection(),
                              if (_isEditing) ...[
                                const SizedBox(
                                  height: 16,
                                ),
                                _buildFilesSection(),
                              ],
                              const SizedBox(
                                height: 16,
                              ),
                              DropdownButtonFormField<BookCategory>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: S.of(context).categories,
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(int.parse(
                                            _selectedCategory.colorCode)),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(int.parse(
                                            _selectedCategory.colorCode)),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                dropdownColor: Color.lerp(
                                    Color(
                                        int.parse(_selectedCategory.colorCode)),
                                    Colors.white,
                                    0.7),
                                style: const TextStyle(color: Colors.black),
                                items: categories.map((category) {
                                  final isSelected =
                                      category == _selectedCategory;
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color(int.parse(
                                                _selectedCategory.colorCode))
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 12),
                                      child: Text(
                                        category.getLocalizedTitle(context),
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                      _checkForChanges();
                                    });
                                  }
                                },
                              ),
                              if (_isEditing) ...[
                                const SizedBox(
                                  height: 16,
                                ),
                                Card(
                                  elevation: 0,
                                  color: Color.lerp(
                                      Color(int.parse(
                                          _selectedCategory.colorCode)),
                                      Colors.white,
                                      0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Color(int.parse(
                                          _selectedCategory.colorCode)),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    title: Text(
                                      S.of(context).review_and_criteria,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReviewScreen(
                                            userId: widget.userId,
                                            category: _selectedCategory,
                                            book: _finishedBook!,
                                          ),
                                        ),
                                      );

                                      if (result is Map && result['reload'] == true) {
                                        setState(() {
                                          if (result['book'] != null) {
                                            _finishedBook = result['book'];
                                          }
                                        });
                                      }
                                    },
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Card(
                                  elevation: 0,
                                  color: Color.lerp(
                                      Color(int.parse(
                                          _selectedCategory.colorCode)),
                                      Colors.white,
                                      0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Color(int.parse(
                                          _selectedCategory.colorCode)),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    title: Text(
                                      S.of(context).moments,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MomentsScreen(
                                            userId: widget.userId,
                                            category: _selectedCategory,
                                            book: _finishedBook!,
                                          ),
                                        ),
                                      );

                                      if (result is Map && result['reload'] == true) {
                                        setState(() {
                                          if (result['book'] != null) {
                                            _finishedBook = result['book'];
                                          }
                                        });
                                      }
                                    },
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(
                                height: 24,
                              ),
                              ElevatedButton(
                                onPressed: _saveBook,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(Color(
                                          int.parse(
                                              _selectedCategory.colorCode))),
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 6),
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
                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                cursorColor: Color(int.parse(_selectedCategory.colorCode)),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: S.of(context).add_link,
                  labelStyle: const TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 0.5,
                        color: Color(int.parse(_selectedCategory.colorCode))),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 1.5,
                        color: Color(int.parse(_selectedCategory.colorCode))),
                  ),
                ),
                onSubmitted: (_) => _addLink(),
              ),
            ),
            IconButton(
              onPressed: _addLink,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Color(int.parse(_selectedCategory.colorCode)),
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
                icon: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
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
            const SizedBox(
              width: 8,
            ),
            IconButton(
              onPressed: () async {
                setState(() {
                  _isDownloading = true;
                });
                final downloadUrl = await _bookFileService.uploadFile();
                if (downloadUrl != null) await _loadBookFiles();
                if (mounted) {
                  setState(() {
                    _isDownloading = false;
                  });
                }
              },
              icon: _isDownloading
                  ? const CircularProgressIndicator(
                      color: Color(0xFF89B0D9),
                    )
                  : const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Color(int.parse(_selectedCategory.colorCode)),
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
            color: Color(int.parse(_selectedCategory.colorCode)),
          )
        else
          ..._files.map((file) => ListTile(
                title: Text(
                  file,
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _bookFileService.openSavedFile(file),
                      icon:
                          const Icon(Icons.remove_red_eye, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.black),
                      onPressed: _isDownloading
                          ? () => const CircularProgressIndicator(
                                color: Color(0xFF89B0D9),
                              )
                          : () => _downloadFile(file),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
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

  void _addLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).an_error_occurred,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        SnackBar(
          content: Text(
            S.of(context).an_error_occurred,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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

  Future<void> _downloadFile(String fileName) async {
    setState(() => _isDownloading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final bookId = _finishedBook!.id;

      final file = await _bookFileService.downloadToDownloads(
          userId: userId,
          bookId: bookId,
          fileName: fileName,
          pathPart: 'readBooks');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📥 ${S.of(context).file_saved}: ${file.path}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${S.of(context).an_error_occurred}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.bookCategory.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<DateTime?> _showCustomDatePicker({
    required BuildContext context,
    required DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    try {
      final categoryColor = Color(int.parse(_selectedCategory.colorCode));

      return await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: categoryColor,
                onPrimary: Colors.black,
                surface: Color.lerp(categoryColor, Colors.white, 0.7) ??
                    Theme.of(context).scaffoldBackgroundColor,
                onSurface: Colors.black,
              ),
              textTheme: Theme.of(context).textTheme.copyWith(
                    titleLarge: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    titleMedium: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    bodyLarge: const TextStyle(
                      color: Colors.black,
                    ),
                    bodySmall: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: categoryColor,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child!,
            ),
          );
        },
      );
    } catch (e) {
      return await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      cursorColor: Color(int.parse(_selectedCategory.colorCode)),
      style: const TextStyle(color: Colors.black),
      onChanged: (value) => _checkForChanges(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              width: 0.5, color: Color(int.parse(_selectedCategory.colorCode))),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              width: 1.5, color: Color(int.parse(_selectedCategory.colorCode))),
        ),
      ),
      maxLines: maxLines,
    );
  }
}
