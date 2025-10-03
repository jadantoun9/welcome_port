class NotificationModel {
  final String title;
  final String description;
  final String url;
  final String dateAdded;

  NotificationModel({
    required this.dateAdded,
    required this.description,
    required this.title,
    required this.url,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      dateAdded: json['date_added'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
