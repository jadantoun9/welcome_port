import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/orders/models/order.dart';

class OrdersService {
  Future<Either<String, List<OrderModel>>> getBookings({
    required int limit,
    required int page,
    required String search,
  }) async {
    try {
      final response = await Singletons.dio.get(
        "/orders/limit/$limit/page/$page/search/$search",
      );
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

  Future<Either<String, bool>> acceptBooking({
    required String orderReference,
  }) async {
    try {
      await Singletons.dio.post("/orders/$orderReference/accept-by-supplier");
      return const Right(true);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
