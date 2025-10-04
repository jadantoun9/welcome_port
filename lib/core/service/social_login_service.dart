import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';

// Helper function to get localized strings without BuildContext
String _getLocalizedString(String key) {
  final locale = Singletons.sharedPref.getString('locale') ?? 'en';

  switch (key) {
    case 'failedToGetGoogleData':
      return locale == 'ar'
          ? 'فشل الحصول على البيانات المطلوبة من جوجل'
          : 'Failed to get required data from Google';
    case 'failedToGetAppleEmail':
      return locale == 'ar'
          ? 'فشل الحصول على البريد الإلكتروني من تسجيل الدخول بآبل'
          : 'Failed to get email from Apple sign in';
    default:
      return key;
  }
}

// Define a class to handle the three possible outcomes
class LoginResult {
  final CustomerModel? user;
  final String? error;
  final bool isCancelled;

  LoginResult.success(this.user) : error = null, isCancelled = false;

  LoginResult.error(String errorMessage)
    : error = errorMessage,
      user = null,
      isCancelled = false;

  LoginResult.cancelled() : user = null, error = null, isCancelled = true;

  bool get isSuccess => user != null;
  bool get isError => error != null;
}

class SocialLoginService {
  Future<LoginResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser =
          await GoogleSignIn(scopes: ['profile', 'email']).signIn();

      if (gUser == null) {
        return LoginResult.cancelled();
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      if (gUser.email.isEmpty || gAuth.accessToken == null) {
        return LoginResult.error(_getLocalizedString('failedToGetGoogleData'));
      }

      final displayNameParts = (gUser.displayName ?? '').split(' ');

      final firstName = displayNameParts.isNotEmpty ? displayNameParts[0] : '';
      final lastName = displayNameParts.length > 1 ? displayNameParts[1] : '';

      final result = await _serverSocialLogin(
        firstName: firstName,
        lastName: lastName,
        email: gUser.email,
        accessToken: gAuth.accessToken!,
        provider: 'google',
      );

      return result.fold(
        (error) => LoginResult.error(error),
        (user) => LoginResult.success(user),
      );
    } catch (e) {
      return LoginResult.error(getDefaultErrorMessage());
    }
  }

  Future<LoginResult> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Check if the user cancelled the sign-in
      if (credential.identityToken == null) {
        return LoginResult.cancelled();
      }

      String? email = credential.email;
      String? firstName = credential.givenName;
      String? lastName = credential.familyName;

      if (credential.givenName != null) {
        await Singletons.sharedPref.setString(
          SharedConstants.appleGivenNameKey,
          credential.givenName!,
        );
      }
      if (credential.familyName != null) {
        await Singletons.sharedPref.setString(
          SharedConstants.appleFamilyNameKey,
          credential.familyName!,
        );
      }

      // Handle first-time and subsequent sign-ins
      if (email != null) {
        // First time sign in - save the data
        await Singletons.sharedPref.setString(
          SharedConstants.appleEmailKey,
          email,
        );
      } else {
        // Subsequent sign in - retrieve email from token or stored data
        if (credential.identityToken != null) {
          final decodedToken = Jwt.parseJwt(credential.identityToken!);
          email = decodedToken['email'];
        }
        if (email == null || email.isEmpty) {
          email = Singletons.sharedPref.getString(
            SharedConstants.appleEmailKey,
          );
        }
        if (firstName == null || firstName.isEmpty) {
          firstName = Singletons.sharedPref.getString(
            SharedConstants.appleGivenNameKey,
          );
        }
        if (lastName == null || lastName.isEmpty) {
          lastName = Singletons.sharedPref.getString(
            SharedConstants.appleFamilyNameKey,
          );
        }
      }

      if (email == null || email.isEmpty) {
        return LoginResult.error(_getLocalizedString('failedToGetAppleEmail'));
      }

      final result = await _serverSocialLogin(
        firstName: firstName,
        lastName: lastName,
        email: email,
        accessToken: credential.identityToken!,
        provider: 'apple',
      );

      return result.fold(
        (error) => LoginResult.error(error),
        (user) => LoginResult.success(user),
      );
    } on SignInWithAppleAuthorizationException {
      return LoginResult.cancelled();
    } catch (e) {
      debugPrint("Error in sign in with apple: $e");
      return LoginResult.error(getDefaultErrorMessage());
    }
  }

  static Future<Either<String, CustomerModel>> _serverSocialLogin({
    required String? firstName,
    required String? lastName,
    required String email,
    required String accessToken,
    required String provider,
  }) async {
    try {
      Map<String, dynamic> data = {
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        "provider": provider,
        "social_access_token": accessToken,
      };

      final response = await Singletons.dio.post('/login_social', data: data);
      return Right(CustomerModel.fromJson(response.data['data']['customer']));
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      return Left(getDefaultErrorMessage());
    }
  }
}
