import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:welcome_port/core/models/setting.dart';

class ZohoHelper {
  static bool _isInitialized = false;

  static Future<void> initializeZoho(Zoho? zohoConfig) async {
    if (_isInitialized || zohoConfig == null) {
      log('Zoho already initialized or config is null');
      return;
    }

    if (!Platform.isIOS && !Platform.isAndroid) {
      log('Zoho SalesIQ only supports iOS and Android');
      return;
    }

    try {
      // Get credentials based on platform
      final credentials =
          Platform.isIOS
              ? zohoConfig.iosCredentials
              : zohoConfig.androidCredentials;

      log("zoho - 1");
      // Setup event listener
      ZohoSalesIQ.eventChannel.listen((event) {
        switch (event["eventName"]) {
          case SIQEvent.visitorRegistrationFailure:
            {
              // Handle visitor registration failure
              ZohoSalesIQ.sendEvent(SIQSendEvent.visitorRegistrationFailure, [
                SalesIQGuestUser(),
              ]);
              break;
            }
        }
      });

      log("zoho - 2");

      // Initialize Zoho SalesIQ
      SalesIQConfiguration configuration = SalesIQConfiguration(
        appKey: credentials.appKey,
        accessKey: credentials.accessKey,
      );

      log("zoho - 3");

      await ZohoSalesIQ.initialize(configuration);

      log("zoho - 4");

      // Hide the default launcher
      ZohoSalesIQ.launcher.show(VisibilityMode.never);

      log("zoho - 5");

      _isInitialized = true;
      log('Zoho SalesIQ initialized successfully');
    } catch (error) {
      log('Zoho SalesIQ initialization failed: $error');
    }
  }

  static void setVisitorInfo({String? name, String? email, String? phone}) {
    if (!_isInitialized) return;

    if (name != null && name.isNotEmpty) {
      ZohoSalesIQ.setVisitorName(name);
    }
    if (email != null && email.isNotEmpty) {
      ZohoSalesIQ.setVisitorEmail(email);
    }
    if (phone != null && phone.isNotEmpty) {
      ZohoSalesIQ.setVisitorContactNumber(phone);
    }
  }

  /// Track page/screen views
  /// This updates both "Currently In" and adds to "Foot Path"
  static void trackPageView(String pageName) {
    if (!_isInitialized) return;

    try {
      ZohoSalesIQ.setPageTitle(pageName);
      debugPrint('Zoho: Tracking page view - $pageName');
    } catch (error) {
      debugPrint('Zoho: Failed to track page view - $error');
    }
  }
}
