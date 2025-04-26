import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../generated/l10n.dart';
import '../../general/profile_screen.dart';

class MainScreenBaseReader extends StatefulWidget {
  const MainScreenBaseReader({super.key});

  @override
  State<MainScreenBaseReader> createState() => _MainScreenBaseReaderState();
}

class _MainScreenBaseReaderState extends State<MainScreenBaseReader> {
  int _selectedPage = 2;

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
              const Center(child: Text('коллекции прочитанного')),
              const Center(child: Text('планы чтения')),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedPage,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.collections_bookmark), label: 'Прочитано'),
                BottomNavigationBarItem(icon: const Icon(Icons.timer), label: 'Планы'),
                BottomNavigationBarItem(icon: const Icon(Icons.account_circle), label: S.of(context).profile),
              ],
              onTap: onSelectTab,
            ),
          ),
        ),
      ),
    );
  }
}