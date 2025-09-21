class AirportSuggestion {
  final int id;
  final String name;
  final String code;
  final String country;
  final List<LocationSuggestion> locations;

  AirportSuggestion({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.locations,
  });

  factory AirportSuggestion.fromJson(Map<String, dynamic> json) {
    return AirportSuggestion(
      id: int.tryParse(json['airport_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      country: json['country'] ?? '',
      locations:
          (json['locations'] as List<dynamic>)
              .map((location) => LocationSuggestion.fromJson(location))
              .toList(),
    );
  }
}

class LocationSuggestion {
  final String name;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
    );
  }
}
