import 'package:flutter/material.dart';

import '../generated/l10n.dart';

enum Status {
  done(Color(0xFF7FBC8C)),
  draft(Color(0xFFA5C6EA)),
  inProgress(Color(0xFFFFB347)),
  frozen(Color(0xFFC5C5C5));

  final Color color;

  const Status(this.color);

  String title(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case Status.done:
        return s.done;
      case Status.draft:
        return s.draft;
      case Status.inProgress:
        return s.inProgress;
      case Status.frozen:
        return s.frozen;
    }
  }

  static Status fromString(String? value) {
    return values.firstWhere(
          (e) => e.name == value,
      orElse: () => Status.draft,
    );
  }
}

class Book {
  late final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String setting;
  final String description;
  final String lastUpdate;
  final Status status;
  final String message;
  final String theme;
  final String? coverUrl;
  final List<String>? files;

  Book({required this.id, required this.authorId, required this.authorName, required this.title,
    required this.description, required this.status, required this.lastUpdate, required this.setting,
    required this.theme, required this.message, required this.coverUrl, required this.files});

  factory Book.fromMap(String id, Map<dynamic, dynamic> map) {
    return Book(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      title: map['title'] ?? '',
      setting: map['setting'] ?? '',
      description: map['description'] ?? '',
      message: map['message'] ?? '',
      theme: map['theme'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      files: List<String>.from(map['files'] ?? []),
      status: Status.fromString(map['status']?.toString()),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }

}