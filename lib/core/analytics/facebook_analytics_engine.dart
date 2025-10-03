import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookAnalyticsEngine {
  static final _instance = FacebookAppEvents();

  static void confirmCheckout() {
    _instance.logPurchase(
      amount: 100,
      currency: 'USD',
    );
  }
}
