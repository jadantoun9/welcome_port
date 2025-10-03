import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';

class SplashService {
  Future<Either<String, Setting>> getSetting() async {
    try {
      final response = await Singletons.dio.get('/setting');
      print(response.data);
      return Right(Setting.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
