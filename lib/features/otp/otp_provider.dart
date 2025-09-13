import 'dart:async';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/success_message.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/features/otp/otp_service.dart';
import 'package:welcome_port/features/otp/utils/otp_timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();

  String _otp = '';
  bool isLoading = false;
  bool isResending = false;
  String? error;

  final service = OTPService();

  // OTP related
  String currentOtp = '';

  Timer? _timer;
  int remainingTimeInSeconds = 0;

  OtpProvider() {
    remainingTimeInSeconds = OTPTimer.getRemainingTimeInS();
    if (remainingTimeInSeconds > 0) {
      startResendTimer();
    }
  }

  void setError(String? value) {
    error = value;
    notifyListeners();
  }

  void setOtp({
    required String value,
    required BuildContext context,
    required SharedProvider sharedProvider,
    required bool isEditProfile,
  }) {
    _otp = value;
    if (otpController.text != value) {
      otpController.text = value;
    }
    if (otpController.text.length == 6) {
      validateForm(
        context,
        sharedProvider: sharedProvider,
        isEditProfile: isEditProfile,
      );
    }
    setError(null);
    notifyListeners();
  }

  void _setResending(bool value) {
    isResending = value;
    notifyListeners();
  }

  String getFormattedRemainingTime(BuildContext context) {
    return OTPTimer.getFormattedRemainingTime(context, fromOutside: false);
  }

  void onOtpChanged(String value) {
    currentOtp = value;
    notifyListeners();
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

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> resendOtp(BuildContext context) async {
    if (!canResend) return;

    _setResending(true);
    setError(null);
    final l = AppLocalizations.of(context)!;

    final result = await service.resendOTP();

    result.fold((error) => setError(error), (_) {
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

    _setResending(false);
  }

  Future validateForm(
    BuildContext context, {
    required SharedProvider sharedProvider,
    required bool isEditProfile,
  }) async {
    final l = AppLocalizations.of(context)!;
    if (_otp.length != 6) {
      setError(l.enterValidOTP);
      return;
    }
    setLoading(true);

    final result = await service.verifyOtp(otp: _otp);

    result.fold((error) => setError(error), (verResponse) async {
      sharedProvider.setCustomer(verResponse.customer);
      if (verResponse.message != null && verResponse.message!.isNotEmpty) {
        showSuccessMessage(context: context, message: verResponse.message!);
      } else if (isEditProfile) {
        showSuccessMessage(
          context: context,
          message: l.profileUpdatedSuccessfully,
        );
      }
      if (isEditProfile) {
        NavigationUtils.pop(context);
        NavigationUtils.pop(context);
      } else {
        NavigationUtils.clearAndPush(context, NavScreen());
      }
    });
    setLoading(false);
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
    _timer?.cancel();
  }
}
