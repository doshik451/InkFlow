import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../general/base/search_poly.dart';
import 'about_book_screen.dart';
import 'books_list_widget.dart';

import '../../../generated/l10n.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).books), centerTitle: true, automaticallyImplyLeading: false,),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_book_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(Icons.add, color: Colors.white,),
          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AboutBookPage(authorId: FirebaseAuth.instance.currentUser!.uid))); }
        ),
        body: Center(
          child: Stack(
            children: [
              BooksListWidget(searchQuery: _searchQuery),
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
