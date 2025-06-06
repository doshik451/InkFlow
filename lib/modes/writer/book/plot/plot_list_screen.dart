import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_writer_model.dart';
import '../../../../models/plot_models.dart';
import '../../../general/base/confirm_delete_base.dart';
import '../../../general/base/delete_swipe_background_base.dart';
import '../../../general/base/search_poly.dart';
import 'about_story_arc_screen.dart';

class PlotListScreen extends StatefulWidget {
  final String bookId;
  final String authorId;
  final Status status;
  final String bookName;

  const PlotListScreen(
      {super.key, required this.bookId, required this.authorId, required this.status, required this.bookName});

  @override
  State<PlotListScreen> createState() => _PlotListScreenState();
}

class _PlotListScreenState extends State<PlotListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.bookName}: ${S.of(context).plot}'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_story_arc_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AboutStoryArcScreen(bookId: widget.bookId, userId: widget.authorId, status: widget.status, bookName: widget.bookName,))); },
        ),
        body: Center(
          child: Stack(
            children: [
              StoryArcsList(bookId: widget.bookId, userId: widget.authorId, searchQuery: _searchQuery, status: widget.status, bookName: widget.bookName,),
              SearchPoly(onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryArcsList extends StatefulWidget {
  final String userId;
  final String bookId;
  final String searchQuery;
  final Status status;
  final String bookName;

  const StoryArcsList({
    super.key,
    required this.bookId,
    required this.userId,
    required this.searchQuery,
    required this.status, required this.bookName
  });

  @override
  State<StoryArcsList> createState() => _StoryArcsListState();
}

class _StoryArcsListState extends State<StoryArcsList> {
  late DatabaseReference _databaseReference;
  late Stream<DatabaseEvent> _stream;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _databaseReference = FirebaseDatabase.instance
          .ref('books/${widget.userId}/${widget.bookId}/plot');
      _stream = _databaseReference.onValue;
    });
  }

  Future<Map<String, String>> _loadAdditionalData() async => {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${S.current.an_error_occurred} ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),
          );
        }

        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_story_arc,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        final storyArcsMap = data;
        List<StoryArc> storyArcs = storyArcsMap.entries
            .map((entry) => StoryArc.fromMap(
                entry.key, entry.value as Map<dynamic, dynamic>))
            .toList();
        storyArcs.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder(
          future: _loadAdditionalData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${S.current.an_error_occurred} ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: widget.status.color,),
              );
            }

            List<StoryArc> filteredStoryArcs = widget.searchQuery.isEmpty
                ? storyArcs
                : storyArcs.where((item) {
                    final title = item.title.toLowerCase();
                    final desc = item.description.toLowerCase();
                    return title.contains(widget.searchQuery) ||
                        desc.contains(widget.searchQuery);
                  }).toList();

            if (filteredStoryArcs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      S.of(context).no_story_arc,
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
                itemCount: filteredStoryArcs.length,
                itemBuilder: (context, index) {
                  final item = filteredStoryArcs[index];
                  return _StoryArcCard(storyArc: item, index: index, userId: widget.userId, bookId: widget.bookId, status: widget.status, bookName: widget.bookName,);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StoryArcCard extends StatelessWidget {
  final StoryArc storyArc;
  final int index;
  final String userId;
  final String bookId;
  final Status status;
  final String bookName;
  static const duration = Duration(milliseconds: 500);
  const _StoryArcCard({required this.storyArc, required this.index, required this.userId, required this.bookId, required this.status, required this.bookName});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(storyArc.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteStoryArc(storyArc.id, bookId, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToStoryArcDetail(context, storyArc),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: storyArcCardContent(storyArc, context, status),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToStoryArcDetail(BuildContext context, StoryArc storyArc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AboutStoryArcScreen(storyArc: storyArc, bookId: bookId, userId: userId, status: status, bookName: bookName,),
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

  Future<void> _deleteStoryArc(String storyArcId, String bookId, String userId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref('books/$userId/$bookId/plot/$storyArcId').remove();
      await _updateBook();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.current.record_is_deleted,
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
            '${S.current.an_error_occurred}: $e',
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

Widget storyArcCardContent(StoryArc storyArc, BuildContext context, Status status) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 4,
    color: Color.lerp(status.color, Colors.white, 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: status.color,
        width: 2,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    storyArc.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Text(
              storyArc.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  S.current.lastUpdate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14
                  ),
                ),
                Flexible(
                  child: Text(
                    storyArc.lastUpdate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 14
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


