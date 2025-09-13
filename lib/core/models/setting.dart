import 'package:welcome_port/core/helpers/error_helpers.dart';

class Setting {
  final String activeLanguage;
  final List<LanguageModel> languages;
  final String activeCurrency;
  final List<CurrencyModel> currencies;
  final String logo;
  final int privacyPolicy;
  final int termsAndConditions;
  final List<InformationModel> information;
  final UpdateModel? update;
  final CustomerModel? customer;

  Setting({
    required this.activeLanguage,
    required this.languages,
    required this.activeCurrency,
    required this.currencies,
    required this.logo,
    required this.privacyPolicy,
    required this.termsAndConditions,
    required this.information,
    required this.update,
    required this.customer,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      activeLanguage: json['active_language'] ?? '',
      languages:
          json['languages'] != null
              ? (json['languages'] as List)
                  .map((e) => LanguageModel.fromJson(e))
                  .toList()
              : [],
      activeCurrency: json['active_currency'] ?? '',
      currencies:
          json['currencies'] != null
              ? (json['currencies'] as List)
                  .map((e) => CurrencyModel.fromJson(e))
                  .toList()
              : [],
      logo: json['logo'] ?? '',
      privacyPolicy: json['privacy_policy'] ?? 0,
      termsAndConditions: json['terms_and_confitions'] ?? 0,
      information:
          json['information'] != null
              ? (json['information'] as List)
                  .map((e) => InformationModel.fromJson(e))
                  .toList()
              : [],
      update:
          json['update'] != null ? UpdateModel.fromJson(json['update']) : null,
      customer:
          json['customer'] != null
              ? CustomerModel.fromJson(json['customer'])
              : null,
    );
  }
}

class CustomerModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String type;
  final int balance;
  final String balanceFormatted;

  CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.type,
    required this.balance,
    required this.balanceFormatted,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['customer_id'] ?? 0,
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: addPlus(json['telephone'] ?? ''),
      type: json['type'] ?? '',
      balance: int.tryParse(json['balance'].toString()) ?? 0,
      balanceFormatted: json['balance_formatted'] ?? '',
    );
  }
}

class LanguageModel {
  final String code;
  final String name;

  LanguageModel({required this.code, required this.name});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(code: json['code'] ?? '', name: json['name'] ?? '');
  }
}

class CurrencyModel {
  final String code;
  final String name;

  CurrencyModel({required this.code, required this.name});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(code: json['code'] ?? '', name: json['name'] ?? '');
  }
}

class InformationModel {
  final int informationId;
  final String title;

  InformationModel({required this.informationId, required this.title});

  factory InformationModel.fromJson(Map<String, dynamic> json) {
    return InformationModel(
      informationId: json['information_id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class UpdateModel {
  final bool force;
  final OsUpdateModel? ios;
  final OsUpdateModel? android;

  UpdateModel({required this.force, required this.ios, required this.android});

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      force: json['force'] ?? true,
      ios: json['ios'] != null ? OsUpdateModel.fromJson(json['ios']) : null,
      android:
          json['android'] != null
              ? OsUpdateModel.fromJson(json['android'])
              : null,
    );
  }
}

class OsUpdateModel {
  final String version;
  final String url;

  OsUpdateModel({required this.version, required this.url});

  factory OsUpdateModel.fromJson(Map<String, dynamic> json) {
    return OsUpdateModel(
      version: json['version'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
