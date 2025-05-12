import 'package:flutter/material.dart';

import '../generated/l10n.dart';

enum BookInPlanPriority {
  high(Color(0xFFE57373)),
  medium(Color(0xFFFFB74D)),
  low(Color(0xFF81C784)),
  notDefined(Color(0xFF9FA8DA));

  final Color color;

  const BookInPlanPriority(this.color);

  String title(BuildContext context) {
    switch (this) {
      case BookInPlanPriority.high:
        return S.of(context).high;
      case BookInPlanPriority.medium:
        return S.of(context).medium;
      case BookInPlanPriority.low:
        return S.of(context).low;
      case BookInPlanPriority.notDefined:
        return S.of(context).notDefined;
    }
  }

  static BookInPlanPriority fromString(String? value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookInPlanPriority.notDefined,
    );
  }
}

class BookInPlan {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String authorName;
  final String genreNTags;
  final BookInPlanPriority priority;
  final String lastUpdate;
  final List<String>? files;
  final List<String>? links;

  BookInPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.authorName,
    required this.genreNTags,
    required this.priority,
    required this.lastUpdate,
    required this.files,
    required this.links,
  });

  factory BookInPlan.fromMap(String id, Map<dynamic, dynamic> map) {
    return BookInPlan(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorName: map['authorName'] ?? '',
      genreNTags: map['genreNTags'] ?? '',
      priority: BookInPlanPriority.fromString(map['priority']),
      lastUpdate: map['lastUpdate'].toString(),
      files: List<String>.from(map['files'] ?? []),
      links: List<String>.from(map['links'] ?? []),
    );
  }
}
