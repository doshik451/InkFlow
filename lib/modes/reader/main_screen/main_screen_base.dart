import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../plans_to_read/plans_list_screen.dart';
import '../read_book/category_list_screen.dart';

import '../../general/profile_screen.dart';

class MainScreenBaseReader extends StatefulWidget {
  const MainScreenBaseReader({super.key});

  @override
  State<MainScreenBaseReader> createState() => _MainScreenBaseReaderState();
}

class _MainScreenBaseReaderState extends State<MainScreenBaseReader> {
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
              const CategoryListPage(),
              const PlansListScreen(),
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
                BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark, size: _selectedPage == 0 ? 28 : 18,), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.timer, size: _selectedPage == 1 ? 28 : 18,), label: ''),
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