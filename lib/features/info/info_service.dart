import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/info/models/info_model.dart';

class InfoService {
  Future<Either<String, InfoDetailsModel>> getInfo(String id) async {
    try {
      final response = await Singletons.dio.get('/information/$id');
      return Right(
        InfoDetailsModel.fromJson(response.data['data']['information']),
      );
    } on DioException catch (err) {
      return Left(getMessageFromError(err));
    } catch (err) {
      debugPrint(err.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
