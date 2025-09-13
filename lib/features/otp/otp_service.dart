import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/otp/models/verification_response.dart';

class OTPService {
  Future<Either<String, VerificationResponse>> verifyOtp({
    required String otp,
  }) async {
    try {
      final response = await Singletons.dio.post(
        '/otp/email',
        data: {'otp': otp},
      );
      final customer = VerificationResponse.fromJson(response.data['data']);
      return Right(customer);
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
