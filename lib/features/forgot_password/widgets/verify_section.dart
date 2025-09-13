import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifySection extends StatelessWidget {
  const VerifySection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForgotPasswordProvider>(context);
    final l = AppLocalizations.of(context)!;

    if (provider.resendError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
          context: context,
          message: provider.resendError!,
        ).then((value) => provider.setResendError(null));
      });
    }

    return Form(
      key: provider.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.verifyEmail,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(l.enterVerificationCode),
          const SizedBox(height: 20),
          Directionality(
            textDirection: TextDirection.ltr,
            child: PinCodeTextField(
              appContext: context,
              length: 6,
              controller: provider.otpController,
              onChanged: (value) => provider.setOtp(context: context),
              autoDisposeControllers: false,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 48,
                fieldWidth: 48,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                activeColor: AppColors.primaryColor,
                inactiveColor: Colors.grey[300]!,
                selectedColor: AppColors.primaryColor,
                borderWidth: 1,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (provider.verifyOTPError != null)
            ErrorDisplay(message: provider.verifyOTPError!),
          WideButton(
            text: l.verify,
            isLoading: provider.isVerifyOTPLoading,
            onPressed: () => provider.verifyOTP(context: context),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.didntReceiveCode, style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                InkwellWithOpacity(
                  clickedOpacity: !provider.canResend ? 1 : 0.5,
                  onTap: () => provider.resendOtp(context),
                  child:
                      provider.isResending
                          ? const Loader(
                            color: AppColors.primaryColor,
                            size: 18,
                          )
                          : Text(
                            provider.canResend
                                ? l.resend
                                : l.resendIn(
                                  provider.getFormattedRemainingTime(context),
                                ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  provider.canResend
                                      ? AppColors.primaryColor
                                      : null,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
