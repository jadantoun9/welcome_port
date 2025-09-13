import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationHandler {
  static Future<void> initialize() async {
    try {
      // Initialize OneSignal with your app ID
      OneSignal.initialize("ef8f2a88-0e60-40c6-818d-e478e2ef1ccb");
      // Enable debug logging for troubleshooting
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Request notification permission with proper error handling
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint("Error initializing OneSignal: $e");
    }
  }
}
