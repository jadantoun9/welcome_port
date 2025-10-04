import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/helpers/zoho_helper.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/features/splash/splash_service.dart';

class SharedProvider extends ChangeNotifier {
  Setting? setting;
  CustomerModel? customer;
  int selectedIndex = 0;
  Locale? _locale;
  String? _currency;

  Locale get locale {
    if (_locale != null) return _locale!;

    final prevLocale = Locale(
      Singletons.sharedPref.getString(SharedConstants.languageKey) ?? 'en',
    );
    _locale = prevLocale;
    return prevLocale;
  }

  String get currency {
    if (_currency != null) return _currency!;

    final prevCurrency =
        Singletons.sharedPref.getString(SharedConstants.currencyKey) ?? 'USD';
    _currency = prevCurrency;
    return prevCurrency;
  }

  void changeLocale(Locale locale) {
    _locale = locale;
    Singletons.sharedPref.setString(
      SharedConstants.languageKey,
      locale.languageCode,
    );
    notifyListeners();
  }

  void changeCurrency(String currency) {
    _currency = currency;
    Singletons.sharedPref.setString(SharedConstants.currencyKey, currency);
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> setSetting(Setting setting) async {
    this.setting = setting;

    if (setting.activeLanguage.isNotEmpty &&
        setting.activeLanguage != locale.languageCode) {
      changeLocale(Locale(setting.activeLanguage));
    }

    if (setting.activeCurrency.isNotEmpty &&
        setting.activeCurrency != currency) {
      changeCurrency(setting.activeCurrency);
    }

    // Initialize Zoho with credentials from backend before setting customer
    if (setting.chatType == ChatType.zoho) {
      await ZohoHelper.initializeZoho(setting.zoho);
    }

    setCustomer(setting.customer);

    notifyListeners();
  }

  void setCustomer(CustomerModel? customerData) {
    if (customerData != null) {
      OneSignal.login(customerData.id.toString());
      customer = customerData;
      log(
        "filling user info of ${customerData.firstName} ${customerData.lastName}",
      );

      // Set Zoho visitor info
      ZohoHelper.setVisitorInfo(
        name: '${customerData.firstName} ${customerData.lastName}',
        email: customerData.email,
        phone: customerData.phone,
      );
    } else {
      customer = null;
      OneSignal.logout();

      ZohoHelper.setVisitorInfo(name: null, email: null, phone: null);
    }
    notifyListeners();
  }

  Future<void> refreshSetting() async {
    final splashService = SplashService();
    final result = await splashService.getSetting();

    result.fold((error) {}, (newSetting) async {
      await setSetting(newSetting);
    });
  }
}
