import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkflow/modes/writer/book/books_list_screen.dart';
import '../idea/ideas_list_screen.dart';

import '../../../generated/l10n.dart';
import '../../general/profile_screen.dart';

class MainScreenBaseWriter extends StatefulWidget {
  const MainScreenBaseWriter({super.key});

  @override
  State<MainScreenBaseWriter> createState() => _MainScreenBaseWriterState();
}

class _MainScreenBaseWriterState extends State<MainScreenBaseWriter> {
  int _selectedPage = 0;

  void onSelectTab(int index) {
    if(_selectedPage == index) return;
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color navBarColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.transparent;

    return WillPopScope(
      onWillPop: () async {
        Platform.isAndroid ? SystemNavigator.pop() : exit(0);
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navBarColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: IndexedStack(
            index: _selectedPage,
            children: [
              const BooksListScreen(),
              const IdeasListScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedPage,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.book, size: _selectedPage == 0 ? 28 : 18,), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.lightbulb, size: _selectedPage == 1 ? 28 : 18,), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: _selectedPage == 2 ? 28 : 18,), label: ''),
              ],
              onTap: onSelectTab,
            ),
          ),
        ),
      ),
    );
  }
}
