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
  final String outwardDate;
  final String returnDate;
  final Vehicle vehicle;
  final String supplierStatus;


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
    required this.outwardDate,
    required this.returnDate,
    required this.vehicle,
    required this.supplierStatus,
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
      outwardDate:
          json['outward_date'].length > 0
              ? json['outward_date'].substring(0, 10)
              : '',
      returnDate:
          json['return_date'].length > 0
              ? json['return_date'].substring(0, 10)
              : '',
      vehicle: Vehicle.fromJson(json['vehicle']),
      supplierStatus: json['supplier_status'] ?? '',
    );
  }
}
