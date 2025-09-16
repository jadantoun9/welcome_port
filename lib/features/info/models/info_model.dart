class InfoDetailsModel {
  final int id;
  final String title;
  final String description;
  final String image;

  InfoDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory InfoDetailsModel.fromJson(Map<String, dynamic> json) {
    return InfoDetailsModel(
      id: int.tryParse(json['information_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
