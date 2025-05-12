import 'package:flutter/material.dart';
import '../../general/base/search_poly.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
              SearchPoly(onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              }),
            ],
          ),
        ),
      ),
    );
  }
}
