import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/booking_details/models/flight_suggestion.dart';

class BookingDetailsService {
  Future<Either<String, List<FlightSuggestion>>> autocompleteFlightNumber(
    String search,
  ) async {
    try {
      final response = await Singletons.dio.get(
        '/autocomplete/flight-number/$search',
      );
      final quotes = response.data['data']['flight_numbers'] as List<dynamic>;
      List<FlightSuggestion> flightSuggestions =
          quotes.map((quote) => FlightSuggestion.fromJson(quote)).toList();
      return Right(flightSuggestions);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, Unit>> book({
    required String title,
    required String firstName,
    required String lastName,
    required String telephone,
    required String email,
    required List<String> childrenAges,
    required List<String> infantAges,
    required String departureDate,
    required String? returnDate,
    required String flightNumber,
    required String? returnFlightNumber,
    required String airlineCode,
    required String? returnAirlineCode,
    required String addressDetails,
    required bool isOneWay,
    required bool isLocationToAirport,
  }) async {
    try {
      // Convert string ages to integers, handle empty lists
      final childrenAgesInt =
          childrenAges.isEmpty
              ? <int>[]
              : childrenAges.map((age) => int.parse(age)).toList();
      final infantAgesInt =
          infantAges.isEmpty
              ? <int>[]
              : infantAges.map((age) => int.parse(age)).toList();

      // Structure the data based on your requirements
      final Map<String, dynamic> requestData = {
        'customer': {
          'title': title,
          'firstname': firstName,
          'lastname': lastName,
          'telephone': telephone,
          'email': email,
        },
        'children_ages': childrenAgesInt,
        'infants_ages': infantAgesInt,
        'outward': _buildOutwardData(
          departureDate,
          flightNumber,
          addressDetails,
          isLocationToAirport,
          airlineCode,
        ),
      };

      // Add return data only if not one-way
      if (!isOneWay &&
          returnDate != null &&
          returnFlightNumber != null &&
          returnAirlineCode != null) {
        requestData['return'] = _buildReturnData(
          returnDate,
          returnFlightNumber,
          isLocationToAirport,
          addressDetails,
          returnAirlineCode,
        );
      }

      final response = await Singletons.dio.post(
        '/transfer/prebook',
        data: requestData,
      );

      print(response.data);
      return Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Map<String, dynamic> _buildOutwardData(
    String departureDate,
    String flightNumber,
    String addressDetails,
    bool isLocationToAirport,
    String airlineCode,
  ) {
    if (isLocationToAirport) {
      // Location to Airport: pickup_date in "from", flight info in "to"
      return {
        'from': {
          'pickup_date': departureDate,
          'direction_note': addressDetails,
        },
        'to': {'flight_number': flightNumber, 'airline_code': airlineCode},
      };
    } else {
      // Airport to Location: flight info in "from", pickup_date in "to"
      return {
        'from': {
          'pickup_date': departureDate,
          'flight_number': flightNumber,
          'airline_code': airlineCode,
        },
        'to': {'direction_note': addressDetails},
      };
    }
  }

  Map<String, dynamic> _buildReturnData(
    String returnDate,
    String returnFlightNumber,
    bool isLocationToAirport,
    String addressDetails,
    String returnAirlineCode,
  ) {
    if (isLocationToAirport) {
      // Return: Airport to Location - flight info in "from", direction_note in "to"
      return {
        'from': {
          'pickup_date': returnDate,
          'flight_number': returnFlightNumber,
          'airline_code': returnAirlineCode,
        },
        'to': {'direction_note': addressDetails},
      };
    } else {
      return {
        'from': {'pickup_date': returnDate, 'direction_note': addressDetails},
        'to': {
          'flight_number': returnFlightNumber,
          'airline_code': returnAirlineCode,
        },
      };
    }
  }
}
