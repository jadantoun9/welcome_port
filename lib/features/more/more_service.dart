import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class MoreService {
  Future<Either<String, Unit>> logout() async {
    try {
      await Singletons.dio.post('/logout');
      return Right(unit);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      return Left(getDefaultErrorMessage());
    }
  }
}
