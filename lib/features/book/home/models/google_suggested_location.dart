import 'dart:convert';

class GoogleSuggestedLocation {
  final String mainText;
  final String secondaryText;
  final String description;
  final String placeId;
  final List<String> types;

  GoogleSuggestedLocation({
    required this.mainText,
    required this.secondaryText,
    required this.description,
    required this.placeId,
    required this.types,
  });

  factory GoogleSuggestedLocation.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>?;
    final mainText = structuredFormatting?['main_text'] as String? ?? '';
    final secondaryText =
        structuredFormatting?['secondary_text'] as String? ?? '';

    return GoogleSuggestedLocation(
      mainText: mainText,
      secondaryText: secondaryText,
      description: json['description'] as String? ?? '',
      placeId: json['place_id'] as String? ?? '',
      types:
          (json['types'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          [],
    );
  }

  // Convert the location to a JSON map
  Map<String, dynamic> _toJson() {
    return {
      'structured_formatting': {
        'main_text': mainText,
        'secondary_text': secondaryText,
      },
      'description': description,
      'place_id': placeId,
    };
  }

  String toJsonString() {
    return json.encode(_toJson());
  }

  // Create a location from a SharedPreferences string
  static GoogleSuggestedLocation fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return GoogleSuggestedLocation.fromJson(json);
  }
}
