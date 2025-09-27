import 'package:welcome_port/core/models/quote.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';

class OrderModel {
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
  final String dateAdded;
  final Vehicle vehicle;

  OrderModel({
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
    required this.dateAdded,
    required this.vehicle,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
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
      dateAdded: json['date_added'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle']),
    );
  }
}
