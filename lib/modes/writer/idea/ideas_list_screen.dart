import 'package:flutter/material.dart';
import 'animated_idea_list.dart';

import '../../../../generated/l10n.dart';
import 'idea_info_screen.dart';

class IdeasListScreen extends StatefulWidget {
  const IdeasListScreen({super.key});

  @override
  State<IdeasListScreen> createState() => _IdeasListScreenState();
}

class _IdeasListScreenState extends State<IdeasListScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.ideas), centerTitle: true, automaticallyImplyLeading: false,),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_idea_tag',
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const IdeaInfoScreen())); },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      body: Center(
        child: Stack(
          children: [
            AnimatedIdeaList(searchQuery: _searchQuery),
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
                  isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                  hintText: S.current.search, hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 3, color: Theme.of(context).colorScheme.secondary),),
                  prefixIcon: const Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.secondary),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
