import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

class AuthService {
  static Future<Either<String, Unit>> refreshToken() async {
    String clientId = 'shopping_oauth_client';
    String clientSecret = 'shopping_oauth_secret';

    // creating a FormData object
    FormData formData = FormData.fromMap({
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    try {
      final response = await Singletons.dio.post(
        '/oauth2/token/client_credentials',
        data: formData,
      );

      // if request is successful, we store the access token in shared prefs
      Map<String, dynamic> responseData = response.data;
      final token = responseData['data']['access_token'];
      if (token != null && token.isNotEmpty) {
        Singletons.sharedPref.setString(SharedConstants.tokenKey, token);
        return Right(unit);
      }
      return Left(getDefaultErrorMessage());
    } on DioException catch (err) {
      return Left(getMessageFromError(err));
    } catch (err) {
      return Left(getDefaultErrorMessage());
    }
  }

  static Future<Either<String, bool>> logOut() async {
    try {
      await Singletons.dio.post('/logout');
      return const Right(true);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      return Left(getDefaultErrorMessage());
    }
  }
}
