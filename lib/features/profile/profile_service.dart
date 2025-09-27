import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';

class ProfileService {
  Future<Either<String, CustomerModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await Singletons.dio.put(
        '/account',
        data: {
          if (firstName != null) 'firstname': firstName,
          if (lastName != null) 'lastname': lastName,
          if (email != null) 'email': email,
          if (phone != null) 'telephone': removePlus(phone),
        },
      );
      final customer = CustomerModel.fromJson(
        response.data['data']['customer'],
      );
      return Right(customer);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }

  Future<Either<String, Unit>> deleteProfile() async {
    try {
      await Singletons.dio.delete('/account');
      return Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
