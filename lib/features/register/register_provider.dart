import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/features/otp/otp_screen.dart';
import 'package:welcome_port/features/register/register_service.dart';

class RegisterProvider extends ChangeNotifier {
  final service = RegisterService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String registerError = "";
  bool isLoading = false;

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

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);
    setRegisterError("");

    final result = await service.register(
      emailController.text.trim(),
      passwordController.text,
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
