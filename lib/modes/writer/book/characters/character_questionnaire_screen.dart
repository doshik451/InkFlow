import 'package:flutter/material.dart';
import 'additional_info_widget.dart';
import 'biography_widget.dart';
import 'character_profile_widget.dart';
import 'relationship_form_widget.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterProfileWidget(
                userId: widget.userId,
                bookId: widget.bookId,
                characterId: widget.character.id,
              ),
              const SizedBox(height: 8,),
              BiographyWidget(
                userId: widget.userId,
                bookId: widget.bookId,
                characterId: widget.character.id,
              ),
              const SizedBox(height: 8,),
              RelationshipFormWidget(
                userId: widget.userId,
                bookId: widget.bookId,
                characterId: widget.character.id,
              ),
              const SizedBox(height: 8,),
              AdditionalInfoWidget(
                userId: widget.userId,
                bookId: widget.bookId,
                characterId: widget.character.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}