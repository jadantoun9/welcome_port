import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/features/otp/otp_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OTPScreen extends StatelessWidget {
  final String email;
  final bool isEditProfile;

  const OTPScreen({super.key, required this.email, this.isEditProfile = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OtpProvider(),
      child: OTPScreenContent(email: email, isEditProfile: isEditProfile),
    );
  }
}

class OTPScreenContent extends StatelessWidget {
  final String email;
  final bool isEditProfile;

  const OTPScreenContent({
    super.key,
    required this.email,
    this.isEditProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OtpProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Email Verification",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Show error message if any
                    if (provider.error != null)
                      ErrorDisplay(
                        message: provider.error!,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: "Please enter the code sent to "),
                          TextSpan(
                            text: email,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " to verify your account"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: provider.otpController,
                        onChanged:
                            (value) => provider.setOtp(
                              value: value,
                              context: context,
                              sharedProvider: sharedProvider,
                              isEditProfile: isEditProfile,
                            ),
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
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l.didntReceiveCode,
                            style: TextStyle(fontSize: 14),
                          ),
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
                                            provider.getFormattedRemainingTime(
                                              context,
                                            ),
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
                    Expanded(child: Container()),
                    WideButton(
                      text: l.verify,
                      isLoading: provider.isLoading,
                      onPressed: () async {
                        await provider.validateForm(
                          context,
                          sharedProvider: sharedProvider,
                          isEditProfile: isEditProfile,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
