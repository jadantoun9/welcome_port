import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/home/models/google_suggested_location.dart';

class GoogleMapUtils {
  static const languageCode = 'en';
  static String languageParams = languageCode;

  static Future<List<GoogleSuggestedLocation>?> getSuggestionsForKeyword({
    required String keyword,
    required String gmKey,
    required String countryCode,
  }) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$keyword&key=${gmKey}&language=$languageParams${countryCode.isNotEmpty ? '&components=country:$countryCode' : ''}';
      final response = await Singletons.dio.get(url);
      List<dynamic> results = response.data['predictions'];
      List<GoogleSuggestedLocation> suggLocations =
          results.map((res) => GoogleSuggestedLocation.fromJson(res)).toList();

      // remove all airport types
      suggLocations =
          suggLocations
              .where((location) => !location.types.contains('airport'))
              .toList();
      return suggLocations;
    } on DioException catch (err) {
      debugPrint(
        "LocationService.getSuggestionsForKeyword error: ${err.response?.data}",
      );
    } catch (err) {
      debugPrint("LocationService.getSuggestionsForKeyword error: $err");
    }
    return null;
  }

  static Future<GMPlaceDetails?> getPlaceDetails(
    String placeId,
    String gmKey,
  ) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,address_components&key=$gmKey';

    try {
      final response = await Singletons.dio.get(url);
      if (response.data == null) return null;

      final result = response.data['result'];
      if (result == null) return null;

      // Extract coordinates
      final geometry = result['geometry'];
      final location = geometry?['location'];
      if (location == null) return null;

      double lat = location['lat'];
      double lng = location['lng'];

      // Extract country code safely
      String countryCode = '';
      final addressComponents = result['address_components'] as List<dynamic>?;

      if (addressComponents != null && addressComponents.isNotEmpty) {
        // Find the country component
        for (final component in addressComponents) {
          final types = component['types'] as List<dynamic>?;
          if (types != null && types.contains('country')) {
            countryCode = component['short_name'] as String? ?? '';
            break;
          }
        }

        // Fallback: if no country component found, try the last component
        if (countryCode.isEmpty) {
          final lastComponent = addressComponents.last;
          countryCode = lastComponent['short_name'] as String? ?? '';
        }
      }

      // if country code is not 2 characters, it's wrong, set it to empty
      if (countryCode.length != 2) {
        countryCode = '';
      }

      return GMPlaceDetails(latLng: LatLng(lat, lng), countryCode: countryCode);
    } catch (err) {
      debugPrint("getPlaceDetails error: $err");
      return null;
    }
  }
}

class GMPlaceDetails {
  final LatLng latLng;
  final String countryCode;

  GMPlaceDetails({required this.latLng, required this.countryCode});
}
