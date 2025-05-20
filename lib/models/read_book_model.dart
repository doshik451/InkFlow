import 'package:flutter/material.dart';
import '../generated/l10n.dart';

class FinishedBook {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String description;
  final String genreNTags;
  final String startDate;
  final String endDate;
  final String? overallRating; // 0–100
  final String personalReview;
  final BookCategory category;
  List<BookMoment> moments;
  final Map<String, String> criteria;
  final List<String>? files;
  final List<String>? links;

  FinishedBook({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.overallRating,
    required this.personalReview,
    required this.moments,
    required this.criteria,
    required this.category,
    required this.files,
    required this.links,
    required this.genreNTags,
  });

  Color get ratingColor {
    if (overallRating == null || overallRating == '???') {
      return const Color(0xFFBEBCE1);
    } else {
      if (int.parse(overallRating!) >= 80) return const Color(0xFF81C784);
      if (int.parse(overallRating!) >= 60) return const Color(0xFFAED581);
      if (int.parse(overallRating!) >= 40) return const Color(0xFFFFCE73);
      if (int.parse(overallRating!) >= 20) return const Color(0xFFFFA840);
    }

    return const Color(0xFFE57373);
  }

  factory FinishedBook.fromMap(String id, Map<dynamic, dynamic> map) {
    final rawCriteria = map['criteriaRatings'];

    Map<String, String> criteriaMap = {};

    if (rawCriteria == null) {
      criteriaMap = {};
    } else if (rawCriteria is Map) {
      criteriaMap = rawCriteria.map((key, value) => MapEntry(key.toString(), value.toString()));
    } else if (rawCriteria is List) {
      criteriaMap = {
        for (int i = 0; i < rawCriteria.length; i++)
          if (rawCriteria[i] != null) i.toString() : rawCriteria[i].toString(),
      };
    } else {
      criteriaMap = {};
    }

    return FinishedBook(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      genreNTags: map['genreNTags'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      overallRating: map['overallRating'] ?? '???',
      personalReview: map['personalReview'] ?? '',
        moments: map['moments'] is List
            ? (map['moments'] as List)
            .map((e) => BookMoment.fromMap('', Map<String, dynamic>.from(e)))
            .toList()
            : [],
      criteria: criteriaMap,
      category: BookCategory.fromMap(
        map['categoryId'] ?? '',
        Map<String, dynamic>.from(map['category'] ?? {}),
      ),
      files: List<String>.from(map['files'] ?? []),
      links: List<String>.from(map['links'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'description': description,
      'genreNTags': genreNTags,
      'startDate': startDate,
      'endDate': endDate,
      'overallRating': overallRating,
      'categoryId': category.id,
      'personalReview': personalReview,
      'moments': moments.map((e) => e.toMap()).toList(),
      'criteriaRatings': criteria.map((key, value) => MapEntry(key, value)),
    };
  }
}

class RatingCriterion {
  final String id;
  final String? title;
  final String? titleKey;
  final String? score;
  final bool isCustom;

  RatingCriterion({
    this.title,
    this.titleKey,
    this.score,
    required this.isCustom,
    required this.id
  });

  factory RatingCriterion.fromMap(String id, Map<dynamic, dynamic> map) {
    return RatingCriterion(
      id: id,
      title: map['title'],
      titleKey: map['titleKey'],
      score: map['score'] ?? '0',
      isCustom: map['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleKey': titleKey,
      'score': score,
      'isCustom': isCustom,
    };
  }

  String getLocalizedTitle(BuildContext context) {
    if (isCustom || titleKey == null) return title ?? '';
    final s = S.of(context);
    final map = {
      'criterion_plot': s.criterion_plot,
      'criterion_characters': s.criterion_characters,
      'criterion_worldbuilding': s.criterion_worldbuilding,
      'criterion_emotion': s.criterion_emotion,
      'criterion_writingStyle': s.criterion_writingStyle,
      'criterion_ending': s.criterion_ending,
    };
    return map[titleKey] ?? titleKey!;
  }
}

class BookCategory {
  final String id;
  late final String? title;      // Пользовательская
  final String? titleKey;
  final String colorCode;// Стандартная
  final bool isCustom;

  BookCategory({
    this.title,
    this.titleKey,
    required this.isCustom,
    required this.id,
    required this.colorCode
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory BookCategory.fromMap(String id, Map<dynamic, dynamic> map) {
    return BookCategory(
      id: id,
      title: map['title'],
      titleKey: map['titleKey'],
      isCustom: map['isCustom'] ?? false,
      colorCode: map['colorCode'] ?? '',
    );
  }

  String getLocalizedTitle(BuildContext context) {
    if (isCustom || titleKey == null) return title ?? '';
    final s = S.of(context);
    final map = {
      'category_read': s.category_read,
      'category_favorite': s.category_favorite,
      'category_abandoned': s.category_abandoned,
      'category_reRead': s.category_reRead,
      'category_disliked': s.category_disliked,
      'category_in_process': s.category_in_process
    };
    return map[titleKey] ?? titleKey!;
  }
}

class BookMoment {
  final String id;
  final String type;
  String content;

  BookMoment({
    required this.id,
    required this.type,
    required this.content,
  });

  factory BookMoment.fromMap(String id, Map<dynamic, dynamic> map) {
    return BookMoment(
      id: id,
      type: map['type'] ?? 'text',
      content: map['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'content': content,
    };
  }

  BookMoment copyWith({
    String? id,
    String? type,
    String? content,
  }) {
    return BookMoment(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }
}