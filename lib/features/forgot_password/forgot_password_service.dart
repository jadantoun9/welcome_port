import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class ForgotPasswordService {
  Future<Either<String, Unit>> sendOTPForReset({required String email}) async {
    try {
      await Singletons.dio.post('/forgotten/confirm', data: {'email': email});
      return const Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, String>> verifyOTPForReset({
    required String otp,
  }) async {
    try {
      final response = await Singletons.dio.post(
        '/otp/email',
        data: {'otp': otp},
      );
      return Right(response.data['data']['code'] as String);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, Unit>> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      await Singletons.dio.post(
        '/forgotten/reset',
        data: {'code': code, 'password': newPassword, 'confirm': newPassword},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, Unit>> resendOTP() async {
    try {
      await Singletons.dio.get('/otp/email');
      return Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
