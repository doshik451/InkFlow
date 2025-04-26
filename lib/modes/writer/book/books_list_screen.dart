import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                cursorColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                decoration: InputDecoration(
                  isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
                  hintText: S.of(context).search, hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 3, color: Theme.of(context).colorScheme.secondary)),
                  prefixIcon: const Icon(Icons.search), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.secondary),)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
