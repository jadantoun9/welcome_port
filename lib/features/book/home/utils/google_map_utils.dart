import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/home/models/google_suggested_location.dart';

class GoogleMapUtils {
  static const languageCode = 'en';
  static String languageParams = languageCode;

  static Future<List<GoogleSuggestedLocation>?> getSuggestionsForKeyword(
    String keyword,
    String gmKey,
  ) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$keyword&key=${gmKey}&language=$languageParams';
      final response = await Singletons.dio.get(url);
      print("response: ${response.data}");
      List<dynamic> results = response.data['predictions'];
      List<GoogleSuggestedLocation> suggLocations =
          results.map((res) => GoogleSuggestedLocation.fromJson(res)).toList();
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

  static Future<LatLng?> getPlaceDetails(String placeId, String gmKey) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$gmKey';

    try {
      final response = await Singletons.dio.get(url);
      if (response.data == null) return null;
      double lat = response.data['result']['geometry']['location']['lat'];
      double lng = response.data['result']['geometry']['location']['lng'];
      return LatLng(lat, lng);
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }
}
