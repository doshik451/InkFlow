class Booknote {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final String lastUpdate;

  Booknote({required this.id, required this.authorId, required this.title, required this.description, required this.lastUpdate});

  factory Booknote.fromMap(String id, Map<dynamic, dynamic> map){
    return Booknote(
      id: id,
      authorId: map['authorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}