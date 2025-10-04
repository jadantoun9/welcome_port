import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookAnalyticsEngine {
  static final _instance = FacebookAppEvents();

  /// Track when user views a page/screen
  static void logPageView({required String pageName}) {
    _instance.logEvent(
      name: 'MobilePageView',
      parameters: {'content_type': 'page', 'content': pageName},
    );
  }

  /// Track when user successfully signs in
  static void logSignIn({required String method}) {
    _instance.logEvent(
      name: 'MobileLogin',
      parameters: {
        'login_method': method, // 'email', 'google', 'apple'
      },
    );
  }

  /// Track when user completes a purchase/booking
  static void logPurchase({
    required double amount,
    required String currency,
    required String orderReference,
    String? contentType,
  }) {
    _instance.logPurchase(
      amount: amount,
      currency: currency,
      parameters: {
        'order_reference': orderReference,
        'content_type': contentType ?? 'booking',
      },
    );
  }
}
