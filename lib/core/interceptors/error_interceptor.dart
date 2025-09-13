import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/service/auth_service.dart';

// This interceptor serves to regenerate an access token automatically when
// the access token expires (when the server responds with a 401)
// by invoking refreshToken() method
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // if unauthorized response, we send a request to obtain a new token
        log("refreshing token...");
        await AuthService.refreshToken();
        // retrying the original request with the new generated token
        final response = await _resendRequest(err.requestOptions);
        if (response != null) {
          return handler.resolve(response);
        } else {
          // If resend request returns null, propagate the original error
          return handler.next(err);
        }
      } catch (e) {
        debugPrint('Error during token refresh: $e');
        return handler.next(err);
      }
    }

    // Handle non-401 errors
    // log the error
    if (err.response == null) {
      debugPrint(err.toString());
    }
    final fullUrl = err.requestOptions.uri.toString();
    final bearerToken =
        err.requestOptions.headers['Authorization']?.toString().split(' ').last;

    String errorMessage = '';
    // Extract a more specific error message if available
    if (err.response?.data is Map<String, dynamic>) {
      errorMessage = getMessageFromError(err);
      if (errorMessage == getDefaultErrorMessage()) {
        errorMessage = err.response?.data.toString() ?? err.response.toString();
      }
    } else if (err.response?.data != null) {
      errorMessage = err.response!.data.toString();
    } else {
      errorMessage = err.message ?? 'Unknown error';
    }

    // Log the route and error message
    final contentType =
        err.requestOptions.headers['Content-Type'] ?? 'not specified';
    final requestBody = err.requestOptions.data?.toString() ?? 'no body';
    log(
      '${err.requestOptions.method} request to $fullUrl failed with error: $errorMessage'
      ' (token: $bearerToken, content-type: $contentType, body: $requestBody)',
    );

    // Propagate the error
    return handler.next(err);
  }

  Future<Response?> _resendRequest(RequestOptions requestOptions) async {
    // retrieving the dio object with interceptors
    // (to make sure new access token is sent with the request)
    try {
      // resending request with the new access token and with same information as the first request
      final response = await Singletons.dio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          sendTimeout: requestOptions.sendTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          extra: requestOptions.extra,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          validateStatus: requestOptions.validateStatus,
        ),
        data: requestOptions.data,
      );
      // returning the response
      return response;
    } catch (err) {
      debugPrint('Error resending request: $err');
      return null;
    }
  }
}
