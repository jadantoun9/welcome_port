import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/social_login_section.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/login/login_screen.dart';
import 'package:welcome_port/features/register/register_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(),
      child: RegisterContent(),
    );
  }
}

class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key});

  @override
  State<RegisterContent> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterContent> {
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes to trigger rebuild when focus changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegisterProvider>(context, listen: false);
      provider.emailFocusNode.addListener(() => setState(() {}));
      provider.passwordFocusNode.addListener(() => setState(() {}));
      provider.confirmPasswordFocusNode.addListener(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegisterProvider>(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthHeader(), // White section with form - dynamic height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: provider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      l.registration,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Show error message if any
                    if (provider.registerError.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          provider.registerError,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],

                    // Email field
                    CustomTextField(
                      controller: provider.emailController,
                      hintText: l.email,
                      icon: Icons.email_outlined,
                      focusNode: provider.emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) => provider.validateEmail(value, context),
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    CustomTextField(
                      controller: provider.passwordController,
                      hintText: l.password,
                      icon: Icons.lock_outline,
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
                      focusNode: provider.passwordFocusNode,
                      validator:
                          (value) => provider.validatePassword(value, context),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password field
                    CustomTextField(
                      controller: provider.confirmPasswordController,
                      hintText: l.confirmPassword,
                      icon: Icons.lock_outline,
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
                      focusNode: provider.confirmPasswordFocusNode,
                      validator:
                          (value) =>
                              provider.validateConfirmPassword(value, context),
                    ),

                    const SizedBox(height: 25),
                    WideButton(
                      text: l.register,
                      isDisabled: provider.isLoading,
                      onPressed: () => provider.register(context),
                      isLoading: provider.isLoading,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l.alreadyHaveAccount),
                          const SizedBox(width: 5),
                          InkwellWithOpacity(
                            onTap: () {
                              NavigationUtils.push(context, LoginScreen());
                            },
                            child: Text(
                              l.logIn,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SocialLoginSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
