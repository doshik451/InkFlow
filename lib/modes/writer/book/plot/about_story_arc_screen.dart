import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/book_writer_model.dart';
import '../../../../models/plot_models.dart';
import '../../../general/base/confirm_delete_base.dart';
import '../../../general/base/delete_swipe_background_base.dart';
import 'about_chapter_screen.dart';

class AboutStoryArcScreen extends StatefulWidget {
  final StoryArc? storyArc;
  final String bookId;
  final String userId;
  final Status status;

  const AboutStoryArcScreen(
      {super.key, this.storyArc, required this.bookId, required this.userId, required this.status});

  @override
  State<AboutStoryArcScreen> createState() => _AboutStoryArcScreenState();
}

class _AboutStoryArcScreenState extends State<AboutStoryArcScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late List<Chapter> _chapters = [];

  late String _initialTitle;
  late String _initialDescription;
  bool _hasUnsavedData = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.storyArc?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.storyArc?.description ?? '');

    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;

    if (widget.storyArc != null) {
      _loadChapters();
    }
  }

  Future<void> _loadChapters() async {
    try {
      final snapshot = await _databaseReference
          .child('books/${widget.userId}/${widget.bookId}/plot/${widget.storyArc!.id}/chapters')
          .get();

      if (snapshot.exists) {
        final chapters = (snapshot.value as Map).entries.map((e) {
          return Chapter.fromMap(e.key, Map<dynamic, dynamic>.from(e.value));
        }).toList();

        if (mounted) {
          setState(() {
            _chapters = chapters;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).an_error_occurred}: $e')),
        );
      }
    }
  }

  void _navigateToChapterScreen([Chapter? chapter]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutChapterScreen(
          chapter: chapter,
          userId: widget.userId,
          bookId: widget.bookId,
          arcId: widget.storyArc!.id,
          status: widget.status,
        ),
      ),
    ).then((_) => _loadChapters());
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasDescriptionChanged =
        _descriptionController.text != _initialDescription;

    setState(() {
      _hasUnsavedData = hasTitleChanged || hasDescriptionChanged;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveStoryArc() async {
    final s = S.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showErrorSnackbar(s.an_error_occurred, s.requiredField);
      return;
    }

    try {
      setState(() => _isSaving = true);

      final updateDate = DateTime.now();
      final lastUpdate = DateFormat('yyyy-MM-dd HH:mm').format(updateDate);

      final storyArcData = _createStoryArcData(title, description, lastUpdate);
      final result = await _saveStoryArcToDatabase(storyArcData);

      if (mounted) {
        _initialTitle = title;
        _initialDescription = description;
        _hasUnsavedData = false;
        _showSuccessSnackbar(widget.storyArc != null ? s.update_success : s.create_success);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AboutStoryArcScreen(
              status: widget.status,
              storyArc: result,
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
      debugPrint('StoryArc save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _createStoryArcData(String title, String description, String lastUpdate) {
    return {
      'title': title,
      'description': description,
      'lastUpdate': lastUpdate,
    };
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

  Future<StoryArc> _saveStoryArcToDatabase(Map<String, dynamic> storyArcData) async {
    DatabaseReference storyArcRef;
    String storyArcId;

    if (widget.storyArc != null) {
      storyArcId = widget.storyArc!.id;
      storyArcRef = _databaseReference.child(
        'books/${widget.userId}/${widget.bookId}/plot/$storyArcId',
      );
      await storyArcRef.update(storyArcData);
    } else {
      storyArcRef = _databaseReference.child(
        'books/${widget.userId}/${widget.bookId}/plot',
      ).push();
      storyArcId = storyArcRef.key!;
      await storyArcRef.set(storyArcData);
    }

    await _updateBook();

    return StoryArc(
      id: storyArcId,
      title: storyArcData['title'],
      description: storyArcData['description'],
      lastUpdate: storyArcData['lastUpdate'],
    );
  }

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                  TextButton(onPressed: () { Navigator.of(context).pop(false); _saveStoryArc(); }, child: Text(S.of(context).save, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
                ],
              )
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.storyArc != null ? widget.storyArc!.title : S.of(context).creating),
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveStoryArc,
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
                        ),
                        if (widget.storyArc != null) ...[
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: widget.status.color,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  S.of(context).arcs_chapters,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: widget.status.color.withOpacity(0.5),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToChapterScreen(),
                              icon: const Icon(Icons.add, size: 20, color: Colors.black,),
                              label: Text(S.of(context).add_chapter,
                                  style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(widget.status.color),
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_chapters.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _chapters.length,
                              itemBuilder: (context, index) {
                                final chapter = _chapters[index];
                                return TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Dismissible(
                                      key: Key(chapter.id),
                                      direction: DismissDirection.endToStart,
                                      background: buildSwipeBackground(context),
                                      confirmDismiss: (direction) => confirmDelete(context),
                                      onDismissed: (direction) async {
                                        try {
                                          await _databaseReference
                                              .child('books/${widget.userId}/${widget.bookId}/plot/${widget.storyArc!.id}/chapters/${chapter.id}')
                                              .remove();
                                          setState(() {
                                            _chapters.removeAt(index);
                                          });
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${S.of(context).an_error_occurred}: $e')),
                                            );
                                            setState(() {});
                                          }
                                        }
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        elevation: 0,
                                        color: Color.lerp(
                                            widget.status.color, Colors.white,
                                            0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: widget.status.color,
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          title: Text(
                                            chapter.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          subtitle: chapter.description.isNotEmpty
                                              ? Text(
                                            chapter.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black38),
                                          )
                                              : null,
                                          onTap: () =>
                                              _navigateToChapterScreen(chapter),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                );
                              },
                            ),
                        ],
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
