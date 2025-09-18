import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/features/become_an_agent/become_an_agent_service.dart';
import 'package:welcome_port/features/otp/otp_screen.dart';

class BecomeAnAgentProvider extends ChangeNotifier {
  final service = BecomeAnAgentService();

  final formKey = GlobalKey<FormState>();

  // Personal Information
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Company Information
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyTelephoneController = TextEditingController();
  final instagramUsernameController = TextEditingController();
  final websiteController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Focus nodes
  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final companyNameFocusNode = FocusNode();
  final companyAddressFocusNode = FocusNode();
  final companyTelephoneFocusNode = FocusNode();
  final instagramUsernameFocusNode = FocusNode();
  final websiteFocusNode = FocusNode();

  String registerError = "";
  bool isLoading = false;

  // Error states for each field
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? companyNameError;
  String? companyAddressError;
  String? companyTelephoneError;
  String? instagramUsernameError;
  String? websiteError;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void setLoading(bool newLoading) {
    isLoading = newLoading;
    notifyListeners();
  }

  void setRegisterError(String newRegisterError) {
    registerError = newRegisterError;
    notifyListeners();
  }

  // Setter methods for each field
  void setFirstName(String value) {
    firstNameController.text = value;
    firstNameError = null;
    notifyListeners();
  }

  void setLastName(String value) {
    lastNameController.text = value;
    lastNameError = null;
    notifyListeners();
  }

  void setEmail(String value) {
    emailController.text = value;
    emailError = null;
    notifyListeners();
  }

  void setPhone(String value) {
    phoneController.text = value;
    phoneError = null;
    notifyListeners();
  }

  void setPassword(String value) {
    passwordController.text = value;
    passwordError = null;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    confirmPasswordController.text = value;
    confirmPasswordError = null;
    notifyListeners();
  }

  void setCompanyName(String value) {
    companyNameController.text = value;
    companyNameError = null;
    notifyListeners();
  }

  void setCompanyAddress(String value) {
    companyAddressController.text = value;
    companyAddressError = null;
    notifyListeners();
  }

  void setCompanyTelephone(String value) {
    companyTelephoneController.text = value;
    companyTelephoneError = null;
    notifyListeners();
  }

  void setInstagramUsername(String value) {
    instagramUsernameController.text = value;
    instagramUsernameError = null;
    notifyListeners();
  }

  void setWebsite(String value) {
    websiteController.text = value;
    websiteError = null;
    notifyListeners();
  }

  String? validateFirstName(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.firstNameRequired;
    }
    if (value.length < 2) {
      return l.firstNameTooShort;
    }
    return null;
  }

  String? validateLastName(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.lastNameRequired;
    }
    if (value.length < 2) {
      return l.lastNameTooShort;
    }
    return null;
  }

  String? validateEmail(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.emailRequired;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return l.pleaseEnterValidEmailAddress;
    }
    return null;
  }

  String? validatePhone(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.phoneRequired;
    }
    if (value.length < 10) {
      return l.phoneTooShort;
    }
    return null;
  }

  String? validatePassword(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.passwordRequired;
    }
    if (value.length < 6) {
      return l.passwordMinLength;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.pleaseConfirmPassword;
    }
    if (value != passwordController.text) {
      return l.passwordsDoNotMatch;
    }
    return null;
  }

  String? validateCompanyName(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.companyNameRequired;
    }
    if (value.length < 2) {
      return l.companyNameTooShort;
    }
    return null;
  }

  String? validateCompanyAddress(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.companyAddressRequired;
    }
    if (value.length < 10) {
      return l.companyAddressTooShort;
    }
    return null;
  }

  String? validateCompanyTelephone(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.companyTelephoneRequired;
    }
    if (value.length < 10) {
      return l.companyTelephoneTooShort;
    }
    return null;
  }

  String? validateInstagramUsername(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.instagramUsernameRequired;
    }
    if (value.length < 3) {
      return l.instagramUsernameTooShort;
    }
    if (!value.startsWith('@')) {
      return l.instagramUsernameMustStartWithAt;
    }
    return null;
  }

  String? validateWebsite(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.websiteRequired;
    }
    if (!RegExp(r'^https?:\/\/').hasMatch(value)) {
      return l.websiteMustStartWithHttp;
    }
    return null;
  }

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);
    setRegisterError("");

    final result = await service.registerWithEmail(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim(),
      companyName: companyNameController.text.trim(),
      companyAddress: companyAddressController.text.trim(),
      instagramUsername: instagramUsernameController.text.trim(),
      companyTelephone: companyTelephoneController.text.trim(),
      website: websiteController.text.trim(),
    );
    result.fold(
      (error) {
        setRegisterError(error);
        setLoading(false);
      },
      (success) {
        setLoading(false);
        NavigationUtils.push(
          context,
          OTPScreen(email: emailController.text.trim()),
        );
      },
    );
  }

  @override
  void dispose() {
    // Personal Information controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Company Information controllers
    companyNameController.dispose();
    companyAddressController.dispose();
    companyTelephoneController.dispose();
    instagramUsernameController.dispose();
    websiteController.dispose();

    // Focus nodes
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    companyNameFocusNode.dispose();
    companyAddressFocusNode.dispose();
    companyTelephoneFocusNode.dispose();
    instagramUsernameFocusNode.dispose();
    websiteFocusNode.dispose();

    super.dispose();
  }
}
