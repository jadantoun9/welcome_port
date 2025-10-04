import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/wallet/model/transaction.dart';

class WalletService {
  Future<Either<String, List<Transaction>>> getTransactions({
    required int limit,
    required int page,
  }) async {
    try {
      final response = await Singletons.dio.get(
        "/transactions/limit/$limit/page/$page",
      );
      final transactions =
          (response.data['data']['transactions'] as List<dynamic>)
              .map((transaction) => Transaction.fromJson(transaction))
              .toList();
      return Right(transactions);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, String>> topUpWallet({
    required double amount,
    required String paymentMethodCode,
  }) async {
    try {
      final response = await Singletons.dio.post(
        "/account/wallet-topup",
        data: {"amount": amount, "payment_method": paymentMethodCode},
      );
      return Right(response.data['data']['webview']);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
