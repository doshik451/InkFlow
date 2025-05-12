import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';
import '../../general/base/confirm_delete_base.dart';
import '../../general/base/delete_swipe_background_base.dart';
import '../../general/base/search_poly.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'books_in_category_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final _database = FirebaseDatabase.instance.ref();
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';
  late Future<List<BookCategory>> _categoriesFuture;
  Map<String, int> _bookCountByCategory = {};
  List<FinishedBook> _allBooks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categoriesFuture = _loadCategoriesAndBooks();
    await _countBooksInCategories();
  }

  Future<List<BookCategory>> _loadCategoriesAndBooks() async {
    final categories = <BookCategory>[];
    _allBooks = [];

    try {
      final defaultSnap = await _database.child('defaultCategories').get();
      if (defaultSnap.exists) {
        for (final child in defaultSnap.children) {
          final map = Map<String, dynamic>.from(child.value as Map);
          categories.add(BookCategory.fromMap(child.key ?? '', map));
        }
      }

      if (_userId != null) {
        final customSnap = await _database.child('customCategories/$_userId').get();
        if (customSnap.exists) {
          for (final child in customSnap.children) {
            final map = Map<String, dynamic>.from(child.value as Map);
            categories.add(BookCategory.fromMap(child.key ?? '', map));
          }
        }

        final booksSnap = await _database.child('finishedBooks/$_userId').get();
        if (booksSnap.exists) {
          for (final child in booksSnap.children) {
            final map = Map<dynamic, dynamic>.from(child.value as Map);
            final book = FinishedBook.fromMap(child.key ?? '', map);
            _allBooks.add(book);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    return categories;
  }

  Future<void> _countBooksInCategories() async {
    if (_userId == null) return;

    try {
      final booksSnap = await _database.child('finishedBooks/$_userId').get();
      if (booksSnap.exists) {
        final counts = <String, int>{};
        for (final child in booksSnap.children) {
          final map = child.value as Map<dynamic, dynamic>;
          final categoryId = map['categoryId'];
          if (categoryId is String) {
            counts[categoryId] = (counts[categoryId] ?? 0) + 1;
          }
        }
        setState(() {
          _bookCountByCategory = counts;
        });
      }
    } catch (e) {
      debugPrint('Error counting books: $e');
    }
  }

  int _getBookCountForCategory(String categoryId) {
    return _bookCountByCategory[categoryId] ?? 0;
  }

  List<BookCategory> _filterItems(List<BookCategory> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.where((category) {
      final titleMatch = category.getLocalizedTitle(context).toLowerCase().contains(_searchQuery);

      final hasMatchingBooks = _allBooks.any((book) =>
      book.category.id == category.id &&
          (book.title.toLowerCase().contains(_searchQuery) ||
              book.author.toLowerCase().contains(_searchQuery)));

      return titleMatch || hasMatchingBooks;
    }).toList();
  }

  Future<void> _deleteCategoryWithBooks(String categoryId) async {
    if (_userId == null) return;

    try {
      await _database.child('customCategories/$_userId/$categoryId').remove();

      final booksSnap = await _database.child('finishedBooks/$_userId').get();
      if (booksSnap.exists) {
        final updates = <String, dynamic>{};
        for (final child in booksSnap.children) {
          final map = child.value as Map<dynamic, dynamic>;
          if (map['categoryId'] == categoryId) {
            updates['finishedBooks/$_userId/${child.key}'] = null;
          }
        }
        await _database.update(updates);
      }
      await _loadData();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).an_error_occurred}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).collection),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_category',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            showAddCategoryDialog(context, _userId!, () async {
              await _loadData();
              setState(() { });
            });
          },
        ),
        body: Column(
          children: [
            SearchPoly(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<BookCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
      
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text(S.of(context).an_error_occurred));
                    }
      
                    final categories = _filterItems(snapshot.data!);
                    if (categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? S.of(context).no_categories
                                  : S.of(context).no_categories,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }
      
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final bookCount = _getBookCountForCategory(category.id);
      
                        return category.isCustom
                            ? Dismissible(
                          key: Key(category.id),
                          direction: DismissDirection.endToStart,
                          background: buildSwipeBackground(context),
                          confirmDismiss: (direction) => confirmDelete(context),
                          onDismissed: (direction) => _deleteCategoryWithBooks(category.id),
                          child: _buildCategoryCard(category, bookCount),
                        )
                            : _buildCategoryCard(category, bookCount);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BookCategory category, int bookCount) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Color(int.parse(category.colorCode)),
          width: 2,
        ),
      ),
      color: Color.lerp(Color(int.parse(category.colorCode)), Colors.white, 0.7),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCategory(context, category),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCategoryIcon(category, bookCount),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.getLocalizedTitle(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BookCategory category, int bookCount) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color.lerp(Color(int.parse(category.colorCode)), Colors.white, 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(int.parse(category.colorCode)),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          bookCount < 100 ? bookCount.toString() : '99+',
          style: TextStyle(
            color: Color(int.parse(category.colorCode)),
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Future<void> _openCategory(BuildContext context, BookCategory category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BooksInCategoryPage(
          category: category,
        ),
      ),
    );

    await _loadData();
    setState(() {});
  }


  Future<void> showAddCategoryDialog(BuildContext context, String userId, VoidCallback onCategoryAdded) {
    final TextEditingController titleController = TextEditingController();
    Color selectedColor = Colors.blue;

    final s = S.of(context);

    return showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(s.addButton),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(s.title, titleController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(s.color),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(s.selectColor),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (color) {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                enableAlpha: false,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.tertiary)),
                                child: Text(s.ok, style: const TextStyle(color: Colors.white),),
                              )
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(s.cancel),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;

                  setState(() => isSaving = true);

                  final ref = FirebaseDatabase.instance
                      .ref('customCategories/$userId')
                      .push();

                  await ref.set({
                    'title': title,
                    'isCustom': true,
                    'colorCode': selectedColor.value.toRadixString(16).padLeft(8, '0').replaceFirst('', '0x'),
                  });

                  Navigator.pop(context);
                  onCategoryAdded();
                },
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.tertiary)),
                child: Text(s.save, style: const TextStyle(color: Colors.white),),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).colorScheme.tertiary,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 0.5, color: Theme.of(context).colorScheme.tertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      maxLines: maxLines,
    );
  }
}