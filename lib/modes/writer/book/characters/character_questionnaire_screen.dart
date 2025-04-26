import 'package:flutter/material.dart';

import '../../../../models/book_character_model.dart';

class CharacterQuestionnaireScreen extends StatefulWidget {
  final Character character;
  final String bookId;
  final String userId;

  const CharacterQuestionnaireScreen({super.key, required this.character, required this.bookId, required this.userId});

  @override
  State<CharacterQuestionnaireScreen> createState() => _CharacterQuestionnaireScreenState();
}

class _CharacterQuestionnaireScreenState extends State<CharacterQuestionnaireScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
