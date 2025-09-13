import 'package:welcome_port/core/models/setting.dart';

class VerificationResponse {
  CustomerModel? customer;
  String? message;
  String? redirect;

  VerificationResponse({this.customer, this.message, this.redirect});

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      customer:
          json['customer'] != null
              ? CustomerModel.fromJson(json['customer'])
              : null,
      message: json['message'] ?? '',
      redirect: json['redirect'] ?? '',
    );
  }
}
