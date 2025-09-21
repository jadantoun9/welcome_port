class FlightSuggestion {
  final String flightNumber;
  final String airlineLogo;
  final String airlineCode;

  FlightSuggestion({
    required this.flightNumber,
    required this.airlineLogo,
    required this.airlineCode,
  });

  factory FlightSuggestion.fromJson(Map<String, dynamic> json) {
    return FlightSuggestion(
      flightNumber: json['flight_number'] ?? '',
      airlineLogo: json['airline_logo'] ?? '',
      airlineCode: json['airline_code'] ?? '',
    );
  }
}
