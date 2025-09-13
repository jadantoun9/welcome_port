import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_provider.dart';
import 'package:welcome_port/features/forgot_password/widgets/email_section.dart';
import 'package:welcome_port/features/forgot_password/widgets/progress_indicator.dart';
import 'package:welcome_port/features/forgot_password/widgets/reset_section.dart';
import 'package:welcome_port/features/forgot_password/widgets/verify_section.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordProvider(),
      child: _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatelessWidget {
  const _ForgotPasswordContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForgotPasswordProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(),
          ProgressIndicatorWidget(currentStep: provider.currentStep),
          const SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                if (provider.currentStep == 0) EmailSection(),
                if (provider.currentStep == 1) VerifySection(),
                if (provider.currentStep == 2) ResetSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
