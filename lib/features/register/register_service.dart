import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class RegisterService {
  Future<Either<String, Unit>> register(String email, String password) async {
    try {
       await Singletons.dio.post(
        '/register',
        data: {
          'email': email,
          'password': password,
          'confirm': password,
          'type': 'customer',
        },
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint('Registration error: ${e.toString()}');
      return Left(getDefaultErrorMessage());
    }
  }
}
