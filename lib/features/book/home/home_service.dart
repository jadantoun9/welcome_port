import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/home/models/airport_suggestion.dart';
import 'package:welcome_port/features/book/home/models/get_quotes_response.dart';

class HomeService {
  Future<Either<String, List<AirportSuggestion>>> getAirportSuggestions({
    required String search,
    required String countryCode,
  }) async {
    print("filtering on countryCode: $countryCode");
    try {
      final response = await Singletons.dio.get(
        '/autocomplete/airport/$search',
      );
      final airports = response.data['data']['airports'] as List<dynamic>;
      List<AirportSuggestion> airportSuggestions =
          airports
              .map((airport) => AirportSuggestion.fromJson(airport))
              .toList();

      if (countryCode.isNotEmpty) {
        airportSuggestions =
            airportSuggestions
                .where((airport) => airport.countryCode == countryCode)
                .toList();
      }

      return Right(airportSuggestions);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint("error: ${e.toString()}");
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, GetQuotesResponse>> getQuotes({
    required String origin,
    required String destination,
    required String locationName,
    required String locationAddress,
    required String outwardDate,
    required String returnDate,
    required int adults,
    required int children,
    required int babies,
    required String coupon,
  }) async {
    try {
      final response = await Singletons.dio.post(
        '/transfer/quotes',
        data: {
          'origin': origin,
          'destination': destination,
          'location': {'name': locationName, 'address': locationAddress},
          'passengers': "$adults,$children,$babies",
          'outward_date': outwardDate,
          'return_date': returnDate,
          'coupon': coupon,
        },
      );
      print(response.data);
      final quotes = GetQuotesResponse.fromJson(response.data['data']);
      return Right(quotes);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, Unit>> applyCoupon({required String coupon}) async {
    try {
      await Singletons.dio.post('/coupon', data: {'coupon': coupon});
      return Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      return Left(getDefaultErrorMessage());
    }
  }
}
