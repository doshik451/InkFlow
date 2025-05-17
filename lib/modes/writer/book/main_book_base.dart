import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkflow/modes/writer/book/book_notes/booknotes_list_base_screen.dart';
import 'package:inkflow/modes/writer/book/characters/characters_list.dart';
import 'package:inkflow/modes/writer/book/environment/environment_list_screen.dart';
import 'package:inkflow/modes/writer/book/plot/plot_list_screen.dart';
import '../../../models/book_writer_model.dart';
import 'about_book_screen.dart';


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

    _animationController.forward();
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
            PlotListScreen(bookId: widget.book.id, authorId: widget.book.authorId, status: widget.book.status,),
            CharactersListScreen(bookId: widget.book.id, authorId: widget.book.authorId, status: widget.book.status,),
            EnvironmentListScreen(bookId: widget.book.id, authorId: widget.book.authorId, status: widget.book.status,),
            BookNotesListBaseScreen(bookId: widget.book.id, authorId: widget.book.authorId, status: widget.book.status,),
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
              showSelectedLabels: false,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.book, size: _selectedPage == 0 ? 28 : 18,), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book, size: _selectedPage == 1 ? 28 : 18), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.people, size: _selectedPage == 2 ? 28 : 18), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.public, size: _selectedPage == 3 ? 28 : 18), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined, size: _selectedPage == 4 ? 28 : 18), label: ''),
              ],
              onTap: onSelectTab,
            ),
          ),
        ),
      ),
    );
  }
}
