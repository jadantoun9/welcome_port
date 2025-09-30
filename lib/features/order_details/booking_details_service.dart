import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/order_details/models/booking_details.dart';

class BookingDetailsService {
  Future<Either<String, OrderDetailsModel>> getOrder({
    required String reference,
  }) async {
    try {
      final response = await Singletons.dio.get("/orders/$reference");
      final order = OrderDetailsModel.fromJson(response.data['data']['order']);
      return Right(order);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
