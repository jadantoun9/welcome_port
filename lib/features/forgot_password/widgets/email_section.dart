import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailSection extends StatelessWidget {
  const EmailSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForgotPasswordProvider>(context);
    final l = AppLocalizations.of(context)!;

    return Form(
      key: provider.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.enterYourEmail,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(l.enterEmailToReceiveCode),
          const SizedBox(height: 20),
          CustomTextField(
            controller: provider.emailController,
            hintText: l.email,
            icon: Icons.email_outlined,
            focusNode: provider.emailFocusNode,
            validator: (value) => provider.validateEmail(value, context),
          ),
          const SizedBox(height: 20),
          if (provider.sendOTPError != null)
            ErrorDisplay(message: provider.sendOTPError!),
          WideButton(
            onPressed: () => provider.sendOTP(context: context),
            text: l.continueText,
            isLoading: provider.isSendOTPLoading,
          ),
        ],
      ),
    );
  }
}
