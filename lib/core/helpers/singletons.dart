import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welcome_port/core/connection/network_di.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/interceptors/error_interceptor.dart';
import 'package:welcome_port/core/interceptors/request_interceptor.dart';

class Singletons {
  static late SharedPreferences sharedPref;
  static late Dio dio;
  static late PackageInfo packageInfo;

  static Future init() async {
    NetworkDi.init();
    sharedPref = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    dio = Dio(BaseOptions(baseUrl: SharedConstants.baseUrl));
    dio.interceptors.add(RequestInterceptor());
    dio.interceptors.add(ErrorInterceptor());
  }
}
