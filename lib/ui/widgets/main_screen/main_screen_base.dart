import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../generated/l10n.dart';
import 'profile_screen.dart';

class MainScreenBase extends StatefulWidget {
  const MainScreenBase({super.key});

  @override
  State<MainScreenBase> createState() => _MainScreenBaseState();
}

class _MainScreenBaseState extends State<MainScreenBase> {
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
              Center(child: Text('data1')),
              Center(child: Text('data2')),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedPage,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.book), label: S.of(context).books),
                BottomNavigationBarItem(icon: const Icon(Icons.lightbulb), label: S.of(context).ideas),
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
