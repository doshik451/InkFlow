import 'package:flutter/material.dart';

import '../../../../models/book_character_model.dart';

class CharacterReferencesScreen extends StatefulWidget {
  final Character character;
  final String bookId;
  final String userId;

  const CharacterReferencesScreen({super.key, required this.character, required this.bookId, required this.userId});

  @override
  State<CharacterReferencesScreen> createState() => _CharacterReferencesScreenState();
}

class _CharacterReferencesScreenState extends State<CharacterReferencesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
