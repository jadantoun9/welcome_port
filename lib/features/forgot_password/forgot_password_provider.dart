import 'dart:async';

import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/success_message.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_service.dart';
import 'package:welcome_port/features/login/login_screen.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/features/otp/utils/otp_timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  int currentStep = 0;
  final service = ForgotPasswordService();

  // first page
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final otpFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final formKey = GlobalKey<FormState>();
  String resetCode = "";

  bool isSendOTPLoading = false;
  String? sendOTPError;

  bool isVerifyOTPLoading = false;
  String? verifyOTPError;

  bool isResetPasswordLoading = false;
  String? resetPasswordError;

  bool isResending = false;
  String? resendError;

  void setCurrentStep(int value) {
    currentStep = value;
    notifyListeners();
  }

  // first page
  void setEmail(String value) {
    emailController.text = value;
    notifyListeners();
  }

  void setVerifyOTPLoading(bool value) {
    isVerifyOTPLoading = value;
    notifyListeners();
  }

  void setVerifyOTPError(String? value) {
    verifyOTPError = value;
    notifyListeners();
  }

  void setSendOTPLoading(bool value) {
    isSendOTPLoading = value;
    notifyListeners();
  }

  void setSendOTPError(String? value) {
    sendOTPError = value;
    notifyListeners();
  }

  void setResetPasswordLoading(bool value) {
    isResetPasswordLoading = value;
    notifyListeners();
  }

  void setResetPasswordError(String? value) {
    resetPasswordError = value;
    notifyListeners();
  }

  void setResendError(String? value) {
    resendError = value;
    notifyListeners();
  }

  void setResending(bool value) {
    isResending = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  String? validatePassword(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.newPasswordRequired;
    }
    if (value.length < 6) {
      return l.passwordMustBeAtLeast6;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.confirmPasswordRequired;
    }
    if (value != passwordController.text) {
      return l.passwordsDoNotMatch;
    }
    return null;
  }

  String? validateEmail(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l.emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return l.pleaseEnterValidEmailAddress;
    }

    return null;
  }

  Future<void> sendOTP({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setSendOTPLoading(true);
    setSendOTPError(null);

    final result = await service.sendOTPForReset(
      email: emailController.text.trim(),
    );
    result.fold((error) => setSendOTPError(error), (response) {
      setCurrentStep(1);
    });
    setSendOTPLoading(false);
  }

  Future<void> verifyOTP({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setVerifyOTPLoading(true);
    setVerifyOTPError(null);

    final result = await service.verifyOTPForReset(
      otp: otpController.text.trim(),
    );
    result.fold((error) => setVerifyOTPError(error), (response) {
      resetCode = response;
      setCurrentStep(2);
    });
    setVerifyOTPLoading(false);
  }

  Future<void> resetPassword({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setResetPasswordLoading(true);
    setResetPasswordError(null);

    final result = await service.resetPassword(
      code: resetCode,
      newPassword: passwordController.text.trim(),
    );
    result.fold((error) => setResetPasswordError(error), (response) {
      final l = AppLocalizations.of(context)!;
      showSuccessMessage(
        context: context,
        message: l.passwordResetSuccessfully,
      );
      NavigationUtils.clearAndPush(context, NavScreen());
      NavigationUtils.push(context, LoginScreen());
    });
    setResetPasswordLoading(false);
  }

  void setOtp({required BuildContext context}) {
    if (otpController.text.length == 6) {
      verifyOTP(context: context);
    }
    notifyListeners();
  }

  //FOR OTP RESET
  ForgotPasswordProvider() {
    remainingTimeInSeconds = OTPTimer.getRemainingTimeInS();
    if (remainingTimeInSeconds > 0) {
      startResendTimer();
    }
  }

  Timer? _timer;
  int remainingTimeInSeconds = 0;

  String getFormattedRemainingTime(BuildContext context) {
    return OTPTimer.getFormattedRemainingTime(context, fromOutside: false);
  }

  void startResendTimer() {
    // Cancel any existing timer
    _timer?.cancel();

    // Create a new timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTimeInSeconds = OTPTimer.getRemainingTimeInS();

      if (remainingTimeInSeconds > 0) {
        notifyListeners();
      } else {
        // When timer reaches 0, cancel the timer
        timer.cancel();
        notifyListeners();
      }
    });
  }

  bool get canResend => OTPTimer.canRequest();

  Future<void> resendOtp(BuildContext context) async {
    if (!canResend) return;

    setResending(true);
    setResendError(null);
    final l = AppLocalizations.of(context)!;

    final result = await service.resendOTP();

    result.fold((error) => setResendError(error), (_) {
      // Update the OTP timer
      OTPTimer.otpSent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(l.otpCodeResent),
            ],
          ),
        ),
      );
      remainingTimeInSeconds = OTPTimer.getRemainingTimeInS();
      startResendTimer();
    });

    setResending(false);
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    emailFocusNode.dispose();
    otpFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
