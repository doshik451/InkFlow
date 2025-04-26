import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_book_base.dart';
import '../../../models/book_writer_model.dart';
import '../widget_base/confirm_delete_base.dart';
import '../widget_base/delete_swipe_background_base.dart';

import '../../../generated/l10n.dart';
import '../widget_base/book_card_base.dart';

class BooksListWidget extends StatefulWidget {
  final String searchQuery;
  const BooksListWidget({super.key, required this.searchQuery});

  @override
  State<BooksListWidget> createState() => _BooksListWidgetState();
}

class _BooksListWidgetState extends State<BooksListWidget> {
  late String userId;
  late DatabaseReference _userBooksRef;
  late Stream<DatabaseEvent> _booksStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) throw Exception(S.current.an_error_occurred);

    userId = user.uid;
    _userBooksRef = FirebaseDatabase.instance.ref('books/$userId');
    _booksStream = _userBooksRef.onValue;
  }

  Future<Map<String, String>> _loadAdditionalData() async {
    return {};
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _booksStream,
      builder: (context, snapshot) {
        if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
        if(snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(),);
        final data = snapshot.data?.snapshot.value;

        if (data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_books, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        final booksMap = data;
        List<Book> books = booksMap.entries.map((entry) => Book.fromMap(entry.key, entry.value as Map<dynamic, dynamic>)).toList();
        books.sort((a,b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder<Map<String, String>>(
          future: _loadAdditionalData(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (futureSnapshot.hasError) {
              return Center(child: Text('${S.current.an_error_occurred} ${futureSnapshot.error}'));
            }

            List<Book> filteredBooks = widget.searchQuery.isEmpty
                ? books
                : books.where((book) {
              final query = widget.searchQuery.toLowerCase();
              final title = book.title.toLowerCase();
              final status = book.status.title(context).toLowerCase();
              final authorName = book.authorName.toLowerCase();

              return title.contains(query) ||
                  status.contains(query) ||
                  authorName.contains(query);
            }).toList();

            if(filteredBooks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(height: 16),
                    Text(
                      S.current.no_books,
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
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return _BookCard(book: book, index: index, userId: userId);
              }
            );
          }
        );
      }
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final int index;
  final String userId;
  final Duration animationDuration;

  const _BookCard({
    super.key,
    required this.book,
    required this.index,
    required this.userId,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: animationDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(book.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteBook(book.id, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToBookDetail(context, book),
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

  void _navigateToBookDetail(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainBookBase(book: book,),
      ),
    );
  }

  static Future<void> _deleteBook(String bookId, String userId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref('books/$userId/$bookId').remove();
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