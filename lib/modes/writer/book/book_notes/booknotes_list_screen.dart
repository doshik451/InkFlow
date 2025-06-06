import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/book_writer_model.dart';
import '../../../../models/booknote_model.dart';
import '../../../general/base/confirm_delete_base.dart';
import '../../../general/base/delete_swipe_background_base.dart';
import 'booknote_info_screen.dart';

import '../../../../generated/l10n.dart';
import 'note_card_base.dart';

class BooknotesListScreen extends StatefulWidget {
  final String bookId;
  final String authorId;
  final String searchQuery;
  final Status status;
  final String bookName;
  const BooknotesListScreen({super.key, required this.searchQuery, required this.bookId, required this.authorId, required this.status, required this.bookName});

  @override
  State<BooknotesListScreen> createState() => _BooknotesListScreenState();
}

class _BooknotesListScreenState extends State<BooknotesListScreen> {
  late DatabaseReference _databaseReference;
  late Stream<DatabaseEvent> _notesStream;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref('books/${widget.authorId}/${widget.bookId}/notes');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _notesStream = _databaseReference.onValue;
    });
  }

  Future<Map<String, String>> _loadAdditionalData() async {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _notesStream,
      builder: (context, snapshot) {
        if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),);

        final data = snapshot.data?.snapshot.value;
        if(data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_notes, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }
        final notesMap = data;
        List<Booknote> notes = notesMap.entries.map((entry) => Booknote.fromMap(entry.key, entry.value as Map<dynamic, dynamic>)).toList();
        notes.sort((a,b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder<Map<String, String>>(
          future: _loadAdditionalData(),
          builder: (context, snapshot) {
            if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
            if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),);

            List<Booknote> filteredNotes = widget.searchQuery.isEmpty ? notes : notes.where((note) {
              final query = widget.searchQuery.toLowerCase();
              final title = note.title.toLowerCase();
              final desc = note.description.toLowerCase();
              return title.contains(query) || desc.contains(query);
            }).toList();

            if(filteredNotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).no_notes,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return _NoteCard(note: note, index: index, userId: widget.authorId, bookId: widget.bookId, status: widget.status, bookName: widget.bookName,);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Booknote note;
  final int index;
  final String userId;
  final String bookId;
  final Status status;
  final String bookName;
  static const animationDuration = Duration(milliseconds: 500);

  const _NoteCard({
    required this.note,
    required this.index,
    required this.userId,
    required this.bookId,
    required this.status, required this.bookName
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: animationDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteNote(note.id, bookId, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToNoteDetail(context, note, status),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: noteCardContent(note, context, status),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToNoteDetail(BuildContext context, Booknote note, Status status) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BooknoteInfoScreen(note: note, bookId: bookId, userId: userId, status: status, bookName: bookName,),
      ),
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
        'books/$userId/$bookId')
        .update(updates);
  }

  Future<void> _deleteNote(String noteId, String bookId, String userId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref('books/$userId/$bookId/notes/$noteId').remove();
      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).record_is_deleted,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(status.color, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).an_error_occurred,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(status.color, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}