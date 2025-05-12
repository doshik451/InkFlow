import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../general/base/search_poly.dart';
import '../../../models/book_in_plan_model.dart';
import '../../../modes/reader/plans_to_read/book_in_plan_screen.dart';

import '../../../generated/l10n.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../general/base/delete_swipe_background_base.dart';

class PlansListScreen extends StatefulWidget {
  const PlansListScreen({super.key});

  @override
  State<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends State<PlansListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).plan),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_plan_book_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookInPlanScreen(userId: FirebaseAuth.instance.currentUser!.uid))); },
        ),
        body: Center(
          child: Stack(
            children: [
              PlanList(searchQuery: _searchQuery),
              SearchPoly(onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              })
            ],
          ),
        ),
      ),
    );
  }
}

class PlanList extends StatefulWidget {
  final String searchQuery;

  const PlanList({super.key, required this.searchQuery});

  @override
  State<PlanList> createState() => _PlanListState();
}

class _PlanListState extends State<PlanList> {
  late DatabaseReference _databaseReference;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DatabaseEvent> _stream;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref('planBooks/$userId');
    _stream = _databaseReference.onValue;
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
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF89B0D9),
            ),
          );
        }

        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_books_in_plan,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        final booksInPlanMap = data;
        List<BookInPlan> booksInPlan = booksInPlanMap.entries
            .map((entry) => BookInPlan.fromMap(
                entry.key, entry.value as Map<dynamic, dynamic>))
            .toList();
        booksInPlan.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder(
          future: _loadAdditionalData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${S.current.an_error_occurred} ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<BookInPlan> filteredBooksInPlan = widget.searchQuery.isEmpty
                ? booksInPlan
                : booksInPlan.where((item) {
                    final title = item.title.toLowerCase();
                    final genreNTags = item.genreNTags.toLowerCase();
                    final authorName = item.authorName.toLowerCase();
                    final priority = item.priority.title(context).toLowerCase();
                    return title.contains(widget.searchQuery) ||
                        genreNTags.contains(widget.searchQuery) ||
                        authorName.contains(widget.searchQuery) ||
                        priority.contains(widget.searchQuery);
                  }).toList();

            if (filteredBooksInPlan.isEmpty) {
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
                      S.of(context).no_books_in_plan,
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
              itemCount: filteredBooksInPlan.length,
              itemBuilder: (context, index) {
                final item = filteredBooksInPlan[index];
                return BookInPlanCard(book: item, index: index, userId: userId);
              },
            );
          },
        );
      },
    );
  }
}

class BookInPlanCard extends StatelessWidget {
  final BookInPlan book;
  final int index;
  final String userId;
  static const duration = Duration(milliseconds: 500);
  const BookInPlanCard({super.key, required this.book, required this.index, required this.userId,});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(book.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteItem(book.id, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToItemDetail(context, book),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: bookCardContent(book, context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToItemDetail(BuildContext context, BookInPlan book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookInPlanScreen(bookInPlan: book, userId: userId,),
      ),
    );
  }

  Future<void> _deleteItem(String bookId, String userId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref('planBooks/$userId/$bookId').remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.record_is_deleted)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.current.an_error_occurred}: $e')),
      );
    }
  }
}

Widget bookCardContent(BookInPlan book, BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 4,
    color: Color.lerp(book.priority.color, Colors.white, 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: book.priority.color,
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
                    book.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: book.priority.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    book.priority.title(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                Text(
                  '${S.of(context).author}: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14
                  ),
                ),
                Flexible(
                  child: Text(
                    book.authorName,
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
            const SizedBox(height: 8),
            Text(
              book.description,
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
                    book.lastUpdate,
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