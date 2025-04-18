import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/idea_model.dart';
import '../../widget_base/confirm_delete_base.dart';
import '../../widget_base/delete_swipe_background_base.dart';
import '../../widget_base/idea_card_base.dart';

class AnimatedIdeaList extends StatefulWidget {
  final String searchQuery;

  const AnimatedIdeaList({super.key, required this.searchQuery});

  @override
  State<AnimatedIdeaList> createState() => _AnimatedIdeaListState();
}

class _AnimatedIdeaListState extends State<AnimatedIdeaList> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('ideas');
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DatabaseEvent> _ideaStream;
  final Map<String, String> _bookTitlesCache = {};

  @override
  void initState() {
    super.initState();
    _ideaStream = _databaseReference.orderByChild('authorId').equalTo(userId).onValue;
  }

  Future<String> _getBookTitle(String? bookId, BuildContext context) async {
    if (bookId == null) return S.of(context).general;

    if (_bookTitlesCache.containsKey(bookId)) {
      return _bookTitlesCache[bookId]!;
    }

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('books/$bookId/title')
          .get();

      final title = snapshot.value?.toString() ?? S.of(context).general;
      _bookTitlesCache[bookId] = title;
      return title;
    } catch (_) {
      return S.of(context).general;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _ideaStream,
      builder: (context, snapshot) {
        if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);

        final ideasMap = snapshot.data?.snapshot.value as Map<dynamic,dynamic>;
        if(ideasMap == null || ideasMap.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.current.no_ideas, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        List<Idea> ideas = ideasMap.entries.map((entry) => Idea.fromMap(entry.key, entry.value as Map<dynamic,dynamic>)).toList();
        ideas.sort((a,b) => b.title.compareTo(a.title));

        return FutureBuilder<Map<String, String>>(
          future: _loadBookTitles(ideas, context),
          builder: (context, bookTitlesSnapshot) {
            if(bookTitlesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final bookTitles = bookTitlesSnapshot.data ?? {};

            List<Idea> filteredIdeas = widget.searchQuery.isEmpty
                ? ideas
                : ideas.where((idea) {
              final matchesTitle = idea.title.toLowerCase().contains(widget.searchQuery.toLowerCase());
              final matchesStatus = idea.status.title(context).toLowerCase().contains(widget.searchQuery.toLowerCase());
              final bookTitle = bookTitles[idea.linkedBookId ?? ''] ?? '';
              final matchesBookTitle = bookTitle.toLowerCase().contains(widget.searchQuery.toLowerCase());

              return matchesTitle || matchesStatus || matchesBookTitle;
            }).toList();

            if (filteredIdeas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(height: 16),
                    Text(
                      S.current.no_ideas,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
                addAutomaticKeepAlives: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                itemCount: filteredIdeas.length,
                itemBuilder: (context, index) {
                  final idea = filteredIdeas[index];
                  final bookTitle = bookTitles[idea.linkedBookId ?? ''] ?? S.of(context).general;
                  return _animatedIdeaCard(idea, index, context, bookTitle);
                }
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _loadBookTitles(List<Idea> ideas, BuildContext context) async {
    final bookTitles = <String, String>{};
    final bookIds = ideas.map((i) => i.linkedBookId).where((id) => id != null).toSet();

    for (final bookId in bookIds) {
      if (bookId == null) continue;
      if (_bookTitlesCache.containsKey(bookId)) {
        bookTitles[bookId] = _bookTitlesCache[bookId]!;
      } else {
        try {
          final snapshot = await FirebaseDatabase.instance
              .ref('books/$bookId/title')
              .get();
          final title = snapshot.value?.toString() ?? S.of(context).general;
          bookTitles[bookId] = title;
          _bookTitlesCache[bookId] = title;
        } catch (_) {
          bookTitles[bookId] = S.of(context).general;
        }
      }
    }

    return bookTitles;
  }
}

Widget _animatedIdeaCard(Idea idea, int index, BuildContext context, String bookTitle) {
  const duration = Duration(milliseconds: 500);

  return TweenAnimationBuilder(
    tween: Tween<double>(begin: 0, end: 1),
    duration: duration,
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Dismissible(
        key: Key(idea.id),
        direction: DismissDirection.endToStart,
        background: buildSwipeBackground(context),
        confirmDismiss: (direction) => confirmDelete(context),
        onDismissed: (direction) => _deleteIdea(idea.id, context),
        child: Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: ideaCardContent(idea, context, bookTitle),
          ),
        ),
      );
    },
  );
}

Future<void> _deleteIdea(String ideaId, BuildContext context) async {
  try {
    await FirebaseDatabase.instance.ref('ideas/$ideaId').remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.current.record_is_deleted)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${S.current.an_error_occurred}: $e')),
    );
  }
}