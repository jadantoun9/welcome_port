import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class BecomeAnAgentService {
  Future<Either<String, Unit>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String companyName,
    required String companyAddress,
    required String instagramUsername,
    required String companyTelephone,
    required String website,
  }) async {
    try {
      await Singletons.dio.post(
        '/register',
        data: {
          'email': email,
          'firstname': firstName,
          'lastname': lastName,
          'telephone': removePlus(phone),
          'password': password,
          'confirm': password,
          'type': 'agent',
          "company": {
            "name": companyName,
            "address": companyAddress,
            "telephone": companyTelephone,
            "instagram_username": instagramUsername,
            "website": website,
          },
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
