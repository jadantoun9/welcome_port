import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/login/login_service.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';

class LoginProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  String? _email;
  String? _password;
  String? emailError;
  String? passwordError;
  bool isLoading = false;
  bool isPasswordVisible = false;
  final service = LoginService();
  String? apiError;

  String? get email => _email;
  String? get password => _password;

  void setApiError(String? value) {
    apiError = value;
    notifyListeners();
  }

  void setEmailError(String? value) {
    emailError = value;
    notifyListeners();
  }

  void setPasswordError(String? value) {
    passwordError = value;
    notifyListeners();
  }

  void setEmail(String? value) {
    _email = value;
    emailController.text = value ?? '';
    setEmailError(null);
    setApiError(null);
    notifyListeners();
  }

  void setPassword(String? value) {
    _password = value;
    passwordController.text = value ?? '';
    setPasswordError(null);
    setApiError(null);
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future validateForm(
    BuildContext context,
    SharedProvider sharedProvider,
  ) async {
    setEmailError(null);
    setPasswordError(null);
    setApiError(null);
    final l = AppLocalizations.of(context)!;

    // Validate email
    if (_email == null || _email!.trim().isEmpty) {
      setEmailError(l.pleaseEnterEmail);
      return;
    }

    if (!_isValidEmail(_email!.trim())) {
      setEmailError(l.pleaseEnterValidEmail);
      return;
    }

    // Validate password
    if (_password == null || _password!.trim().isEmpty) {
      setPasswordError(l.pleaseEnterPassword);
      return;
    }

    if (_password!.length < 6) {
      setPasswordError(l.passwordTooShort);
      return;
    }

    setLoading(true);

    final result = await service.login(
      email: _email!.trim(),
      password: _password!.trim(),
    );

    result.fold((error) => setApiError(error), (response) {
      // Navigate to OTP screen for email verification
      sharedProvider.setCustomer(response);
      sharedProvider.setSelectedIndex(0);
      NavigationUtils.push(context, NavScreen());
    });
    setLoading(false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
