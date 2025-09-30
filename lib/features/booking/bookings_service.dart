import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/booking/models/order.dart';

class BookingsService {
  Future<Either<String, List<OrderModel>>> getBookings({
    required int limit,
    required int page,
  }) async {
    try {
      final response = await Singletons.dio.get(
        "/orders/limit/$limit/page/$page",
      );
      print(response.data);
      final orders =
          (response.data['data']['orders'] as List<dynamic>)
              .map((order) => OrderModel.fromJson(order))
              .toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
