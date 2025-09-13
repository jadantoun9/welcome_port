import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class LoginService {
  Future<Either<String, Unit>> login({
    required String email,
    required String password,
  }) async {
    try {
      await Singletons.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
