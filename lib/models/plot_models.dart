class StoryArc {
  final String id;
  final String title;
  final String description;
  final List<Chapter>? chapters;
  final String lastUpdate;

  StoryArc({
    required this.id,
    required this.title,
    required this.description,
    this.chapters,
    required this.lastUpdate,
  });

  factory StoryArc.fromMap(String id, Map<dynamic, dynamic> map) {
    return StoryArc(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      chapters: (map['chapters'] as Map? ?? {}).entries.map((e) {
        return Chapter.fromMap(e.key, Map<dynamic, dynamic>.from(e.value));
      }).toList(),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final String description;
  final List<String> keyMoments;
  final String lastUpdate;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.keyMoments,
    required this.lastUpdate,
  });

  factory Chapter.fromMap(String id, Map<dynamic, dynamic> map) {
    return Chapter(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      keyMoments: List<String>.from(map['keyMoments'] ?? []),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}

