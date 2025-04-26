class BookEnvironmentModel {
  final String id;
  final String title;
  final String description;
  final String features;
  final List<String> images;
  final String lastUpdate;

  BookEnvironmentModel({required this.id, required this.title, required this.description, required this.features, required this.images, required this.lastUpdate});

  factory BookEnvironmentModel.fromMap(String id, Map<dynamic, dynamic> map){
    return BookEnvironmentModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      features: map['features'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}