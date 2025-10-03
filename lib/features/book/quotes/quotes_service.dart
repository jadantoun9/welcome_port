import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/book/quotes/models/prebook_requirements_response.dart';

class QuotesService {
  Future<Either<String, PreBookRequirementsResponse>> preBook(
    String quoteId,
  ) async {
    try {
      final response = await Singletons.dio.post(
        '/transfer/prebook-requirements',
        data: {'quote_id': quoteId},
      );
      return Right(PreBookRequirementsResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(getDefaultErrorMessage());
    }
  }
}
