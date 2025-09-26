import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMLocation {
  final LatLng latLng;
  final String mainText;
  final String secondaryText;
  final String description;
  final String countryCode;

  GMLocation({
    required this.latLng,
    required this.mainText,
    required this.secondaryText,
    required this.description,
    required this.countryCode,
  });
}
