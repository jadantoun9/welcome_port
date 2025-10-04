class Quote {
  String id;
  double price;
  String priceFormatted;
  double? priceDiscounted;
  String priceDiscountedFormatted;
  int durationInMinutes;
  bool isOneWay;
  Vehicle vehicle;

  Quote({
    required this.id,
    required this.price,
    required this.priceFormatted,
    required this.priceDiscounted,
    required this.priceDiscountedFormatted,
    required this.durationInMinutes,
    required this.vehicle,
    required this.isOneWay,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['quote_id'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      priceFormatted: json['price_formatted'] ?? '',
      priceDiscounted:
          json['price_discounted'] != null
              ? double.tryParse(json['price_discounted'].toString())
              : null,
      priceDiscountedFormatted: json['price_discounted_formatted'] ?? '',
      durationInMinutes:
          int.tryParse(json['duration_in_minutes'].toString()) ?? 0,
      vehicle: Vehicle.fromJson(json['vehicle']),
      isOneWay: json['is_oneway'].toString().toLowerCase() == 'true',
    );
  }
}

class Vehicle {
  String name;
  String image;
  String description;
  int maxPassengers;
  int maxLuggage;
  bool isShared;

  Vehicle({
    required this.name,
    required this.image,
    required this.description,
    required this.maxPassengers,
    required this.maxLuggage,
    required this.isShared,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      maxPassengers: int.tryParse(json['max_passengers'].toString()) ?? 0,
      maxLuggage: int.tryParse(json['max_luggage'].toString()) ?? 0,
      isShared: json['is_shared'].toString().toLowerCase() == "true",
    );
  }
}
