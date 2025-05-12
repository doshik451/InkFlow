import 'package:flutter/material.dart';
import '../../../general/base/search_poly.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
