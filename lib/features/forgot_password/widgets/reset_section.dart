import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

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
            l.resetPassword,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(l.createNewPassword),
          const SizedBox(height: 20),
          CustomTextField(
            controller: provider.passwordController,
            hintText: l.newPassword,
            focusNode: provider.passwordFocusNode,
            obscureText: provider.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: provider.togglePasswordVisibility,
            ),
            validator: (value) => provider.validatePassword(value, context),
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: provider.confirmPasswordController,
            hintText: l.confirmPassword,
            icon: Icons.lock_outline,
            focusNode: provider.confirmPasswordFocusNode,
            obscureText: provider.obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: provider.toggleConfirmPasswordVisibility,
            ),
            validator:
                (value) => provider.validateConfirmPassword(value, context),
          ),
          const SizedBox(height: 20),
          if (provider.resetPasswordError != null)
            ErrorDisplay(message: provider.resetPasswordError!),
          WideButton(
            text: l.resetPassword,
            isLoading: provider.isResetPasswordLoading,
            onPressed: () => provider.resetPassword(context: context),
          ),
        ],
      ),
    );
  }
}
