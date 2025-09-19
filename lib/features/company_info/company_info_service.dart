import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';

class CompanyInfoService {
  Future<Either<String, CustomerModel>> updateCompanyInfo({
    String? companyName,
    String? companyAddress,
    String? companyTelephone,
    String? logo,
    String? email,
  }) async {
    try {
      final response = await Singletons.dio.put(
        '/account',
        data: {
          'company': {
            if (companyName != null) 'name': companyName,
            if (email != null) 'email': email,
            if (companyAddress != null) 'address': companyAddress,
            if (companyTelephone != null)
              'telephone': removePlus(companyTelephone),
            if (logo != null) 'logo': logo,
          },
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
}
