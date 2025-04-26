import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkflow/modes/writer/book/book_notes/booknotes_list_base_screen.dart';
import 'package:inkflow/modes/writer/book/characters/characters_list.dart';
import 'package:inkflow/modes/writer/book/environment/environment_list_screen.dart';
import 'package:inkflow/modes/writer/book/plot/plot_list_screen.dart';
import '../../../models/book_writer_model.dart';
import 'about_book_screen.dart';

import '../../../generated/l10n.dart';

class MainBookBase extends StatefulWidget {
  final Book book;
  const MainBookBase({super.key, required this.book});

  @override
  State<MainBookBase> createState() => _MainBookBaseState();
}

class _MainBookBaseState extends State<MainBookBase> with SingleTickerProviderStateMixin {
  int _selectedPage = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.book.id != null) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onSelectTab(int index) {
    if (_selectedPage == index) return;

    if (widget.book.id == null && index != 0) {
      return;
    }

    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color navBarColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.transparent;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedPage,
          children: [
            AboutBookPage(book: widget.book, authorId: widget.book.authorId),
            PlotListScreen(bookId: widget.book.id, authorId: widget.book.authorId,),
            CharactersListScreen(bookId: widget.book.id, authorId: widget.book.authorId),
            EnvironmentListScreen(bookId: widget.book.id, authorId: widget.book.authorId),
            BookNotesListBaseScreen(bookId: widget.book.id, authorId: widget.book.authorId),
          ],
        ),
        bottomNavigationBar: widget.book.id == null
            ? null
            : SizeTransition(
          sizeFactor: _animation,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedPage,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.book), label: S.of(context).aboutBook),
                BottomNavigationBarItem(icon: const Icon(Icons.menu_book), label: S.of(context).plot),
                BottomNavigationBarItem(icon: const Icon(Icons.people), label: S.of(context).characters),
                BottomNavigationBarItem(icon: const Icon(Icons.public), label: S.of(context).environment),
                BottomNavigationBarItem(icon: const Icon(Icons.note_alt_outlined), label: S.of(context).notes),
              ],
              onTap: onSelectTab,
            ),
          ),
        ),
      ),
    );
  }
}
