import 'package:dio/dio.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/helpers/singletons.dart';

// this interceptor serves to automatically add the access token (if available)
// to each sent request
class RequestInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // retrieving access token from shared prefences
    final token = Singletons.sharedPref.getString(SharedConstants.tokenKey);
    final language = Singletons.sharedPref.getString(
      SharedConstants.languageKey,
    );
    final currency = Singletons.sharedPref.getString(
      SharedConstants.currencyKey,
    );

    // if it exists, we append it to the request
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (language != null && language.isNotEmpty) {
      options.headers['x-language'] = language;
    }

    if (currency != null && currency.isNotEmpty) {
      options.headers['x-currency'] = currency;
    }

    super.onRequest(options, handler);
  }
}
