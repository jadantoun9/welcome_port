import 'package:welcome_port/core/models/quote.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';
import 'package:welcome_port/features/book/home/widgets/passenger_picker_screen.dart';

enum Direction { airportToLocation, locationToAirport }

class OrderDetailsModel {
  final String reference;
  final TripType tripType;
  final String tripTypeFormatted;
  final String from;
  final String to;
  final String status;
  final String statusFormatted;
  final double price;
  final String priceFormatted;
  final String paymentMethod;
  final Vehicle vehicle;
  final PassengerData passengers;
  final String voucher;
  final AirportInfo airport;
  final LocationInfo location;
  final Direction routeDirection;
  final String outwardDate;
  final String returnDate;

  OrderDetailsModel({
    required this.reference,
    required this.tripType,
    required this.tripTypeFormatted,
    required this.from,
    required this.to,
    required this.status,
    required this.statusFormatted,
    required this.price,
    required this.priceFormatted,
    required this.paymentMethod,
    required this.passengers,
    required this.vehicle,
    required this.voucher,
    required this.airport,
    required this.routeDirection,
    required this.location,
    required this.outwardDate,
    required this.returnDate,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      reference: json['reference'] ?? '',
      tripType:
          json['type'].toString() == "roundtrip"
              ? TripType.roundTrip
              : TripType.oneWay,
      tripTypeFormatted: json['type_formatted'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      status: json['status'] ?? '',
      statusFormatted: json['status_formatted'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      priceFormatted: json['price_formatted'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle']),
      passengers: PassengerData.fromJson(json['passengers']),
      voucher: json['voucher'] ?? '',
      airport: AirportInfo.fromJson(json['airport']),
      location: LocationInfo.fromJson(json['location']),
      routeDirection:
          json['route_direction'] == "airport_to_location"
              ? Direction.airportToLocation
              : Direction.locationToAirport,
      outwardDate: json['outward_date'] ?? '',
      returnDate: json['return_date'] ?? '',
    );
  }
}

class AirportInfo {
  final String name;
  final String code;

  AirportInfo({required this.name, required this.code});

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(name: json['name'] ?? '', code: json['code'] ?? '');
  }
}

class LocationInfo {
  String name;
  String address;
  String directionNote;

  LocationInfo({
    required this.name,
    required this.address,
    required this.directionNote,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      directionNote: json['direction_note'] ?? '',
    );
  }
}
