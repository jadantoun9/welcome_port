import 'package:welcome_port/features/book/home/home_provider.dart';

class PreBookRequirementsResponse {
  bool isOneWay;
  TripDirection direction;
  Passengers passengers;
  dynamic origin; // Can be ReturnedAirport or ReturnedGMLocation
  dynamic destination; // Can be ReturnedAirport or ReturnedGMLocation
  String outwardFromPickupDate;
  String? returnFromPickupDate;

  PreBookRequirementsResponse({
    required this.isOneWay,
    required this.direction,
    required this.passengers,
    required this.origin,
    required this.destination,
    required this.outwardFromPickupDate,
    this.returnFromPickupDate,
  });

  factory PreBookRequirementsResponse.fromJson(Map<String, dynamic> json) {
    return PreBookRequirementsResponse(
      isOneWay: json['is_onway'].toString().toLowerCase() == 'true',
      direction:
          json['type'].toString().toLowerCase() == "location_to_airport"
              ? TripDirection.toAirport
              : TripDirection.fromAirport,
      passengers: Passengers.fromJson(json['passengers']),
      origin: _parseLocation(json['origin']),
      destination: _parseLocation(json['destination']),
      outwardFromPickupDate: json['outward_from_pickup_date'] ?? '',
      returnFromPickupDate: json['return_from_pickup_date'] ?? '',
    );
  }

  static dynamic _parseLocation(Map<String, dynamic>? locationJson) {
    if (locationJson == null) return null;

    // Check if it's an airport (has 'code' field)
    if (locationJson.containsKey('code')) {
      return ReturnedAirport.fromJson(locationJson);
    } else {
      // Otherwise it's a GMLocation
      return ReturnedGMLocation.fromJson(locationJson);
    }
  }
}

class Passengers {
  int adults;
  int children;
  int infants;

  Passengers({
    required this.adults,
    required this.children,
    required this.infants,
  });

  factory Passengers.fromJson(Map<String, dynamic> json) {
    return Passengers(
      adults: int.tryParse(json['adults'].toString()) ?? 0,
      children: int.tryParse(json['children'].toString()) ?? 0,
      infants: int.tryParse(json['infants'].toString()) ?? 0,
    );
  }
}

class ReturnedGMLocation {
  String name;
  String address;
  String coords;

  ReturnedGMLocation({
    required this.name,
    required this.address,
    required this.coords,
  });

  factory ReturnedGMLocation.fromJson(Map<String, dynamic> json) {
    return ReturnedGMLocation(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      coords: json['coords'] ?? '',
    );
  }
}

class ReturnedAirport {
  String code;
  String name;

  ReturnedAirport({required this.code, required this.name});

  factory ReturnedAirport.fromJson(Map<String, dynamic> json) {
    return ReturnedAirport(code: json['code'] ?? '', name: json['name'] ?? '');
  }
}
