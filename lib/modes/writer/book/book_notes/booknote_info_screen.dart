
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/models/booknote_model.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_writer_model.dart';

class BooknoteInfoScreen extends StatefulWidget {
  final Booknote? note;
  final String bookId;
  final String userId;
  final Status status;
  final String bookName;
  const BooknoteInfoScreen({super.key, this.note, required this.bookId, required this.userId, required this.status, required this.bookName});

  @override
  State<BooknoteInfoScreen> createState() => _BooknoteInfoScreenState();
}

class _BooknoteInfoScreenState extends State<BooknoteInfoScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();

  late String _initialTitle;
  late String _initialDescription;

  bool _hasUnsavedData = false;
  bool _showTitleError = false;
  bool _showDescriptionError = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController = TextEditingController(text: widget.note?.description ?? '');

    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasDescriptionChanged = _descriptionController.text != _initialDescription;

    setState(() {
      _hasUnsavedData = hasTitleChanged || hasDescriptionChanged;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _saveNote() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if(title.isEmpty || description.isEmpty) {
      setState(() {
        _showDescriptionError = description.isEmpty;
        _showTitleError = title.isEmpty;
      });
      return;
    }

    try {
      final updateDate = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');

      if (widget.note != null) {
        await _databaseReference.child('books/${widget.userId}/${widget.bookId}/notes/${widget.note!.id}').update({
          'title': title,
          'description': description,
          'lastUpdate': formatter.format(updateDate).toString(),
        });
      } else {
        await _databaseReference.child('books/${widget.userId}/${widget.bookId}/notes').push().set({
          'authorId': widget.userId,
          'title': title,
          'description': description,
          'lastUpdate': formatter.format(updateDate).toString(),
        });
      }

      await _updateBook();

      if (mounted) {
        setState(() {
          _initialTitle = title;
          _initialDescription = description;
          _hasUnsavedData = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).an_error_occurred}: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedData,
      onPopInvoked: (bool didPop) async {
        if(didPop) return;
        if(_hasUnsavedData){
          final shouldLeave = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(S.of(context).unsaved_data),
                content: Text(S.of(context).want_to_save),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(S.of(context).no, style: TextStyle(color: Theme.of(context).colorScheme.tertiary))),
                  TextButton(onPressed: () { Navigator.of(context).pop(false); _saveNote(); }, child: Text(S.of(context).save, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
                ],
              )
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note != null ? '${widget.bookName}: ${widget.note!.title}' : S.of(context).creating),
          centerTitle: true,
        ),
        body: Center(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                minWidth: 300,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Color.lerp(widget.status.color, Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: widget.status.color)
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          cursorColor: widget.status.color,
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).title,
                            labelStyle: const TextStyle(color: Colors.black),
                            errorText: _showTitleError ? S.of(context).requiredField : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                minLines: 3,
                                onChanged: (value) => _checkForChanges(),
                                keyboardType: TextInputType.multiline,
                                cursorColor: widget.status.color,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: S.of(context).description,
                                  labelStyle: const TextStyle(color: Colors.black),
                                  errorText: _showDescriptionError ? S.of(context).requiredField : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 0.5, color: widget.status.color),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 1.5, color: widget.status.color),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 1.5, color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 1.5, color: Colors.red),
                                  ),
                                ),
                              ),
                            )
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveNote,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(widget.status.color),
                            padding: WidgetStateProperty.all<EdgeInsets>(
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
        ),
      ),
    );
  }
}
