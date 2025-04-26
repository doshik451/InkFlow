import 'package:flutter/material.dart';
import 'booknote_info_screen.dart';
import 'booknotes_list_screen.dart';

import '../../../../generated/l10n.dart';

class BookNotesListBaseScreen extends StatefulWidget {
  final String bookId;
  final String authorId;
  const BookNotesListBaseScreen({super.key, required this.bookId, required this.authorId});

  @override
  State<BookNotesListBaseScreen> createState() => _BookNotesListBaseScreenState();
}

class _BookNotesListBaseScreenState extends State<BookNotesListBaseScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).notes), centerTitle: true, automaticallyImplyLeading: false,),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          heroTag: 'add_book_note_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(Icons.add, color: Colors.white,),
          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => BooknoteInfoScreen(bookId: widget.bookId, userId: widget.authorId,))); }
      ),
      body: Center(
        child: Stack(
          children: [
            BooknotesListScreen(searchQuery: _searchQuery, bookId: widget.bookId, authorId: widget.authorId,),
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
