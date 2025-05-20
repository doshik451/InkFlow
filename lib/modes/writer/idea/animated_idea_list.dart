import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/idea_model.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../general/base/delete_swipe_background_base.dart';
import '../../general/base/idea_card_base.dart';
import 'idea_info_screen.dart';

class AnimatedIdeaList extends StatefulWidget {
  final String searchQuery;

  const AnimatedIdeaList({super.key, required this.searchQuery});

  @override
  State<AnimatedIdeaList> createState() => _AnimatedIdeaListState();
}

class _AnimatedIdeaListState extends State<AnimatedIdeaList> {
  late DatabaseReference _databaseReference;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DatabaseEvent> _ideaStream;
  final Map<String, String> _bookTitlesCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _databaseReference = FirebaseDatabase.instance.ref('ideas/$userId');
      _ideaStream = _databaseReference.onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _ideaStream,
      builder: (context, snapshot) {
        if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),);

        final data = snapshot.data?.snapshot.value;

        if (data == null || data is! Map) {
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

        final ideasMap = data;

        List<Idea> ideas = ideasMap.entries.map((entry) => Idea.fromMap(entry.key, entry.value as Map<dynamic,dynamic>)).toList();
        ideas.sort((a,b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder<Map<String, String>>(
          future: _loadBookTitles(ideas, context),
          builder: (context, bookTitlesSnapshot) {
            if(bookTitlesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary));
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

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                  itemCount: filteredIdeas.length,
                  itemBuilder: (context, index) {
                    final idea = filteredIdeas[index];
                    final bookTitle = bookTitles[idea.linkedBookId ?? ''] ?? S.of(context).general;
                    return _animatedIdeaCard(idea, index, userId, context, bookTitle);
                  }
              ),
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
              .ref('books/$userId/$bookId/title')
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

Widget _animatedIdeaCard(Idea idea, int index, String userId, BuildContext context, String bookTitle) {
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
        onDismissed: (direction) => _deleteIdea(idea.id, userId, context),
        child: GestureDetector(
          onTap: () => _openEditScreen(context, idea),
          child: Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: ideaCardContent(idea, context, bookTitle),
            ),
          ),
        ),
      );
    },
  );
}

void _openEditScreen(BuildContext context, Idea idea) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => IdeaInfoScreen(idea: idea),
    ),
  );
}

Future<void> _deleteIdea(String ideaId, String userId, BuildContext context) async {
  try {
    await FirebaseDatabase.instance.ref('ideas/$userId/$ideaId').remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.current.record_is_deleted,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
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
          '${S.current.an_error_occurred}: $e',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}