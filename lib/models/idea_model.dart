import 'package:flutter/material.dart';

import '../generated/l10n.dart';

enum IdeaStatus {
  done(Color(0xFF7FBC8C)),
  inMind(Color(0xFFA5C6EA)),
  inProgress(Color(0xFFFFB347)),
  canceled(Color(0xFFC5C5C5));

  final Color color;

  const IdeaStatus(this.color);

  String title(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case IdeaStatus.done:
        return s.done;
      case IdeaStatus.inMind:
        return s.inMind;
      case IdeaStatus.inProgress:
        return s.inProgress;
      case IdeaStatus.canceled:
        return s.canceled;
    }
  }

  static IdeaStatus fromString(String? value) {
    return values.firstWhere(
          (e) => e.name == value,
      orElse: () => IdeaStatus.inMind,
    );
  }
}

class Idea {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final IdeaStatus status;
  final String? linkedBookId;
  final String lastUpdate;

  Idea({required this.id, required this.authorId, required this.title, required this.description, required this.status, required this.linkedBookId, required this.lastUpdate});

  factory Idea.fromMap(String id, Map<dynamic, dynamic> map){
    return Idea(
      id: id,
      authorId: map['authorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: IdeaStatus.fromString(map['status']?.toString()),
      linkedBookId: map['linkedBookId']?.toString(),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}