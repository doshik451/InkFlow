import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'read_book_screen.dart';
import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../general/base/delete_swipe_background_base.dart';
import '../../general/base/search_poly.dart';

class BooksInCategoryPage extends StatefulWidget {
  final BookCategory category;
  final String? initialSearchQuery;

  const BooksInCategoryPage({
    super.key,
    required this.category,
    this.initialSearchQuery,
  });

  @override
  State<BooksInCategoryPage> createState() => _BooksInCategoryPageState();
}

class _BooksInCategoryPageState extends State<BooksInCategoryPage> {
  final _db = FirebaseDatabase.instance.ref();
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  late Future<List<FinishedBook>> _futureBooks;
  Future<String>? _categoryTitleFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? '';
    _futureBooks = _loadBooks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryTitleFuture ??= _loadCategoryTitle();
  }

  Future<String> _loadCategoryTitle() async {
    if (_userId == null) return '';
    try {
      if (widget.category.isCustom) {
        final snapshot = await _db
            .child('customCategories')
            .child(_userId)
            .child(widget.category.id)
            .child('title')
            .get();
        return snapshot.value?.toString() ?? '';
      } else {
        final snapshot = await _db
            .child('defaultCategories')
            .child(widget.category.id)
            .child('titleKey')
            .get();

        final titleKey = snapshot.value?.toString();
        if (titleKey == null) return '';

        final s = S.of(context);
        final map = {
          'category_read': s.category_read,
          'category_favorite': s.category_favorite,
          'category_abandoned': s.category_abandoned,
          'category_reRead': s.category_reRead,
          'category_disliked': s.category_disliked,
          'category_in_process': s.category_in_process,
        };

        return map[titleKey] ?? titleKey;
      }
    } catch (e) {
      debugPrint('Error loading category title: $e');
      return '';
    }
  }

  Future<List<FinishedBook>> _loadBooks() async {
    if (_userId == null) return [];
    try {
      final snapshot = await _db.child('finishedBooks/$_userId').get();
      final List<FinishedBook> books = [];

      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          final map = Map<dynamic, dynamic>.from(data);

          if (map['categoryId']?.toString() == widget.category.id) {
            books.add(FinishedBook.fromMap(child.key!, map));
          }
        }
      }
      return books;
    } catch (e) {
      debugPrint('Error loading books: $e');
      throw Exception('Failed to load books');
    }
  }

  Future<void> _deleteBook(String bookId) async {
    if (_userId == null) return;
    try {
      await _db.child('finishedBooks/$_userId/$bookId').remove();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).an_error_occurred,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Color(int.parse(widget.category.colorCode)), Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  List<FinishedBook> _filterBooks(List<FinishedBook> books) {
    if (_searchQuery.isEmpty) return books;
    final query = _searchQuery.toLowerCase();
    return books
        .where((book) =>
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            (book.description.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _categoryTitleFuture,
      builder: (context, titleSnapshot) {
        final title = titleSnapshot.data ?? s.books;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(title, overflow: TextOverflow.ellipsis),
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton(
                heroTag: 'add_book_in_category',
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadBookScreen(
                        userId: _userId!,
                        bookCategory: widget.category,
                      ),
                    ),
                  );

                  if (result is Map && result['reload'] == true) {
                    final FinishedBook book = result['book'];
                    final BookCategory category = result['category'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReadBookScreen(
                          userId: _userId!,
                          bookCategory: category,
                          book: book,
                        ),
                      ),
                    );
                    setState(() {
                      _futureBooks = _loadBooks();
                    });
                  }
                }),
            body: Column(
              children: [
                SearchPoly(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FutureBuilder<List<FinishedBook>>(
                      future: _futureBooks,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary));
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text(s.an_error_occurred));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              _searchQuery.isEmpty ? s.no_books : s.no_books,
                            ),
                          );
                        }

                        final books = _filterBooks(snapshot.data!);
                        if (books.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 60),
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  s.no_books,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _futureBooks = _loadBooks();
                            });
                            await _futureBooks;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final book = books[index];
                              return TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Dismissible(
                                      key: Key(book.id),
                                      direction: DismissDirection.endToStart,
                                      background: buildSwipeBackground(context),
                                      confirmDismiss: (direction) =>
                                          confirmDelete(context),
                                      onDismissed: (_) async {
                                        await _deleteBook(book.id);
                                        setState(() {
                                          _futureBooks = _loadBooks();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Card(
                                          color: Color.lerp(book.ratingColor,
                                              Colors.white, 0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: BorderSide(
                                              color: book.ratingColor,
                                              width: 2,
                                            ),
                                          ),
                                          elevation: 3,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ReadBookScreen(
                                                    userId: _userId!,
                                                    bookCategory:
                                                        widget.category,
                                                    book: book,
                                                  ),
                                                ),
                                              );

                                              if (result is Map &&
                                                  result['reload'] == true) {
                                                setState(() {
                                                  _futureBooks = _loadBooks();
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 24,
                                                    backgroundColor: Color.lerp(
                                                        book.ratingColor,
                                                        Colors.white,
                                                        0.8),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              book.ratingColor,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          book.overallRating ??
                                                              '???',
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            color: book
                                                                .ratingColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          book.title,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${S.of(context).author}: ',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                book.author,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          '${book.startDate.isNotEmpty ?? false ? book.startDate : '...'} - ${book.endDate.isNotEmpty ?? false ? book.endDate : '...'}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        if (book.description
                                                                .isNotEmpty ??
                                                            false)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 6),
                                                            child: Text(
                                                              book.description,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
