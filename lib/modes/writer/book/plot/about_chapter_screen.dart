import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/plot_models.dart';

class AboutChapterScreen extends StatefulWidget {
  final Chapter? chapter;
  final String userId;
  final String bookId;
  final String arcId;

  const AboutChapterScreen({
    super.key,
    this.chapter,
    required this.userId,
    required this.bookId,
    required this.arcId,
  });

  @override
  State<AboutChapterScreen> createState() => _AboutChapterScreenState();
}

class _AboutChapterScreenState extends State<AboutChapterScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _keyMomentsController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final List<String> _keyMoments = [];
  String _newKeyMoment = '';

  late String _initialTitle;
  late String _initialDescription;
  bool _hasUnsavedData = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapter?.title ?? '');
    _descriptionController = TextEditingController(text: widget.chapter?.description ?? '');
    _keyMomentsController = TextEditingController();

    if (widget.chapter?.keyMoments != null) {
      _keyMoments.addAll(widget.chapter!.keyMoments);
    }

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

  void _addKeyMoment() {
    if (_newKeyMoment.trim().isNotEmpty) {
      setState(() {
        _keyMoments.add(_newKeyMoment.trim());
        _keyMomentsController.clear();
        _newKeyMoment = '';
        _hasUnsavedData = true;
      });
    }
  }

  void _removeKeyMoment(int index) {
    setState(() {
      _keyMoments.removeAt(index);
      _hasUnsavedData = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keyMomentsController.dispose();
    super.dispose();
  }

  Future<void> _saveChapter() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).requiredField)),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);
      final updateDate = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');

      final chapterData = {
        'title': title,
        'description': description,
        'keyMoments': _keyMoments,
        'lastUpdate': formatter.format(updateDate).toString(),
      };

      if (widget.chapter != null) {
        await _databaseReference
            .child('books/${widget.userId}/${widget.bookId}/plot/${widget.arcId}/chapters/${widget.chapter!.id}')
            .update(chapterData);
      } else {
        await _databaseReference
            .child('books/${widget.userId}/${widget.bookId}/plot/${widget.arcId}/chapters')
            .push()
            .set(chapterData);
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
          SnackBar(content: Text('${S.current.an_error_occurred}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}/plot/${widget.arcId}')
        .update(updates);
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
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(S.of(context).no,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary)
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      _saveChapter();
                    },
                    child: Text(S.of(context).save,
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ],
              )
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapter != null ? S.of(context).editing : S.of(context).creating),
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
                  color: Color.lerp(const Color(0xFFA5C6EA), Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFA5C6EA))
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _titleController,
                          cursorColor: const Color(0xFFA5C6EA),
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).title,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 0.5, color: Color(0xFFA5C6EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          minLines: 3,
                          onChanged: (value) => _checkForChanges(),
                          keyboardType: TextInputType.multiline,
                          cursorColor: const Color(0xFFA5C6EA),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).description,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 0.5, color: Color(0xFFA5C6EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).key_moments,
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
                                controller: _keyMomentsController,
                                onChanged: (value) => _newKeyMoment = value,
                                cursorColor: const Color(0xFFA5C6EA),
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: S.of(context).add_key_moment,
                                  hintStyle: const TextStyle(color: Colors.black38),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFA5C6EA)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFA5C6EA)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _addKeyMoment,
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFA5C6EA),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_keyMoments.isNotEmpty)
                          Column(
                            children: _keyMoments.asMap().entries.map((entry) {
                              final index = entry.key;
                              final moment = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                color: Color.lerp(const Color(0xFFA5C6EA), Colors.white, 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  title: Text(moment),
                                  textColor: Colors.black87,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 20, color: Colors.black87,),
                                    onPressed: () => _removeKeyMoment(index),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveChapter,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFA5C6EA)),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator( color: Color(0xFFA5C6EA),)
                              : Text(
                            S.of(context).save,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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