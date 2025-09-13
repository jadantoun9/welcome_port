import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/constants.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';

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

  void setSetting(Setting setting) {
    this.setting = setting;

    if (setting.activeLanguage.isNotEmpty &&
        setting.activeLanguage != locale.languageCode) {
      changeLocale(Locale(setting.activeLanguage));
    }

    if (setting.activeCurrency.isNotEmpty &&
        setting.activeCurrency != currency) {
      changeCurrency(setting.activeCurrency);
    }

    if (setting.customer != null) {
      setCustomer(setting.customer!);
    }
    notifyListeners();
  }

  void setCustomer(CustomerModel? customerData) {
    customer = customerData;
    notifyListeners();
  }
}
