import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_environment_model.dart';
import '../../../../models/book_writer_model.dart';
import '../../../general/base/confirm_delete_base.dart';
import '../../../general/base/delete_swipe_background_base.dart';
import '../../../general/base/search_poly.dart';
import 'about_environment_screen.dart';

class EnvironmentListScreen extends StatefulWidget {
  final String bookId;
  final String authorId;
  final Status status;

  const EnvironmentListScreen(
      {super.key, required this.bookId, required this.authorId, required this.status});

  @override
  State<EnvironmentListScreen> createState() => _EnvironmentListScreenState();
}

class _EnvironmentListScreenState extends State<EnvironmentListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).environment),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_book_environment_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AboutEnvironmentScreen(bookId: widget.bookId, userId: widget.authorId, status: widget.status,))); },
        ),
        body: Center(
          child: Stack(
            children: [
              EnvironmentsList(userId: widget.authorId, bookId: widget.bookId, searchQuery: _searchQuery, status: widget.status,),
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

class EnvironmentsList extends StatefulWidget {
  final String userId;
  final String bookId;
  final String searchQuery;
  final Status status;

  const EnvironmentsList({
    super.key,
    required this.bookId,
    required this.userId,
    required this.searchQuery,
    required this.status
  });

  @override
  State<EnvironmentsList> createState() => _EnvironmentsListState();
}

class _EnvironmentsListState extends State<EnvironmentsList> {
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
          .ref('books/${widget.userId}/${widget.bookId}/environment');
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
            child: CircularProgressIndicator(color: widget.status.color,),
          );
        }

        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_environment_items,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        final environmentMap = data;
        List<BookEnvironmentModel> environments = environmentMap.entries
            .map((entry) => BookEnvironmentModel.fromMap(
                entry.key, entry.value as Map<dynamic, dynamic>))
            .toList();
        environments.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder(
          future: _loadAdditionalData(),
          builder: (context, snapshot) {
            if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
            if(snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(),);

            List<BookEnvironmentModel> filteredEnvironmentItems =
                widget.searchQuery.isEmpty
                    ? environments
                    : environments.where((item) {
                        final title = item.title.toLowerCase();
                        final desc = item.description.toLowerCase();
                        return title.contains(widget.searchQuery) ||
                            desc.contains(widget.searchQuery);
                      }).toList();

            if (filteredEnvironmentItems.isEmpty) {
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
                      S.of(context).no_environment_items,
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
                itemCount: filteredEnvironmentItems.length,
                itemBuilder: (context, index) {
                  final item = filteredEnvironmentItems[index];
                  return _EnvironmentItemCard(environment: item, index: index, userId: widget.userId, bookId: widget.bookId, status: widget.status,);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _EnvironmentItemCard extends StatelessWidget {
  final BookEnvironmentModel environment;
  final int index;
  final String userId;
  final String bookId;
  final Status status;
  static const duration = Duration(milliseconds: 500);
  const _EnvironmentItemCard({required this.environment, required this.status, required this.index, required this.userId, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(environment.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteEnItem(environment.id, bookId, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToEnItemDetail(context, environment),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: environmentCardContent(environment, context, status),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEnItemDetail(BuildContext context, BookEnvironmentModel enItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AboutEnvironmentScreen(environment: enItem, bookId: bookId, userId: userId, status: status,),
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

  Future<void> _deleteEnItem(String environmentId, String bookId, String userId, BuildContext context) async {
    try {
      await FirebaseDatabase.instance.ref('books/$userId/$bookId/environment/$environmentId').remove();
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

Widget environmentCardContent(BookEnvironmentModel environment, BuildContext context, Status status) {
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
                    environment.title,
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
              environment.description,
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
                    environment.lastUpdate,
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
