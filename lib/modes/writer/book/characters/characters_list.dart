import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_character_model.dart';
import '../../../../models/book_writer_model.dart';
import '../../../general/base/confirm_delete_base.dart';
import '../../../general/base/delete_swipe_background_base.dart';
import '../../../general/base/search_poly.dart';
import 'about_character_screen.dart';

class CharactersListScreen extends StatefulWidget {
  final String bookId;
  final String authorId;
  final Status status;
  const CharactersListScreen({super.key, required this.bookId, required this.authorId, required this.status});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).characters),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_book_character_tag',
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AboutCharacterScreen(bookId: widget.bookId, userId: widget.authorId, status: widget.status,))); },
        ),
        body: Center(
          child: Stack(
            children: [
              CharactersList(userId: widget.authorId, bookId: widget.bookId, searchQuery: _searchQuery, status: widget.status,),
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

class CharactersList extends StatefulWidget {
  final String userId;
  final String bookId;
  final String searchQuery;
  final Status status;

  const CharactersList({
    super.key,
    required this.bookId,
    required this.userId,
    required this.searchQuery,
    required this.status
  });

  @override
  State<CharactersList> createState() => _CharactersListState();
}

class _CharactersListState extends State<CharactersList> {
  late DatabaseReference _databaseReference;
  late Stream<DatabaseEvent> _stream;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance
        .ref('books/${widget.userId}/${widget.bookId}/characters');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _stream = _databaseReference.onValue;
    });
  }

  Future<Map<String, String>> _loadAdditionalData() async => {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${S.current.an_error_occurred} ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: widget.status.color,),
          );
        }

        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(S.of(context).no_characters,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        final charactersMap = data;
        List<Character> characters = charactersMap.entries
            .map((entry) => Character.fromMap(
            entry.key, entry.value as Map<dynamic, dynamic>))
            .toList();
        characters.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

        return FutureBuilder(
          future: _loadAdditionalData(),
          builder: (context, snapshot) {
            if(snapshot.hasError) return Center(child: Text('${S.current.an_error_occurred} ${snapshot.error}'),);
            if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: widget.status.color,),);

            List<Character> filteredCharacters =
            widget.searchQuery.isEmpty
                ? characters
                : characters.where((item) {
              final title = item.name.toLowerCase();
              final desc = item.role.toLowerCase();
              final race = item.race.toLowerCase();
              return title.contains(widget.searchQuery) ||
                  desc.contains(widget.searchQuery) || race.contains(widget.searchQuery);
            }).toList();

            if (filteredCharacters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      S.of(context).no_characters,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                itemCount: filteredCharacters.length,
                itemBuilder: (context, index) {
                  final item = filteredCharacters[index];
                  return _CharacterItemCard(character: item, index: index, userId: widget.userId, bookId: widget.bookId, status: widget.status,);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CharacterItemCard extends StatelessWidget {
  final Character character;
  final int index;
  final String userId;
  final String bookId;
  final Status status;
  static const duration = Duration(milliseconds: 500);
  const _CharacterItemCard({required this.character, required this.index, required this.userId, required this.bookId, required this.status});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Dismissible(
          key: Key(character.id),
          direction: DismissDirection.endToStart,
          background: buildSwipeBackground(context),
          confirmDismiss: (direction) => confirmDelete(context),
          onDismissed: (direction) => _deleteCharacter(character.id, bookId, userId, context),
          child: GestureDetector(
            onTap: () => _navigateToCharacterDetail(context, character),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: characterCardContent(character, context, status),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCharacterDetail(BuildContext context, Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AboutCharacterScreen(character: character, bookId: bookId, userId: userId, status: status,),
      ),
    );
  }

  Future<void> _updateBook() async {
    final updateDate = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final updates = {
      'lastUpdate': formatter.format(updateDate),
    };

    await FirebaseDatabase.instance
        .ref(
        'books/$userId/$bookId')
        .update(updates);
  }

  Future<void> _deleteCharacter(String characterId, String bookId, String userId, BuildContext context) async {
    final db = FirebaseDatabase.instance.ref('books/$userId/$bookId/characters');

    try {
      final snapshot = await db.get();

      if (snapshot.exists) {
        final charactersData = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in charactersData.entries) {
          final otherCharacterId = entry.key.toString();

          if (otherCharacterId == characterId) continue;

          final questionnaire = entry.value['questionnaire'];
          if (questionnaire != null && questionnaire['relationships'] != null) {
            final relationships = questionnaire['relationships'] as Map<dynamic, dynamic>;

            for (final relationType in ['family', 'friends', 'enemies', 'others']) {
              final relationTypeData = relationships[relationType];

              if (relationTypeData != null) {
                final relationEntries = relationTypeData as Map<dynamic, dynamic>;

                for (final relEntry in relationEntries.entries) {
                  final relationId = relEntry.key.toString();
                  final relationData = relEntry.value as Map<dynamic, dynamic>;

                  if (relationData['characterId'] == characterId) {
                    await db.child('$otherCharacterId/questionnaire/relationships/$relationType/$relationId').remove();
                  }
                }
              }
            }
          }
        }
      }

      await db.child(characterId).remove();

      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.record_is_deleted)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.current.an_error_occurred}: $e')),
      );
    }
  }

}

Widget characterCardContent(Character character, BuildContext context, Status status) {
  final hasMainImage = character.images?.mainImage?.url.isNotEmpty ?? false;
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 4,
    color: Color.lerp(status.color, Colors.white, 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: status.color,
        width: 2,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: status.color, width: 2),
                image: hasMainImage
                    ? DecorationImage(
                  image: NetworkImage(character.images!.mainImage!.url),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: hasMainImage ? null : Icon(Icons.person, size: 30, color: status.color),
            ),
            const SizedBox(width: 16,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character.appearanceDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        S.current.lastUpdate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14
                        ),
                      ),
                      Flexible(
                        child: Text(
                          character.lastUpdate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 14
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
