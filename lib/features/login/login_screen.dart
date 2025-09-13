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
import 'package:welcome_port/features/login/login_provider.dart';
import 'package:welcome_port/features/register/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes to trigger rebuild when focus changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LoginProvider>(context, listen: false);
      provider.emailFocusNode.addListener(() => setState(() {}));
      provider.passwordFocusNode.addListener(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: provider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      l.login,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Show API error message if any
                    if (provider.apiError != null) ...[
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
                          provider.apiError!,
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
                      errorText: provider.emailError,
                      onChanged: (value) => provider.setEmail(value),
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    CustomTextField(
                      controller: provider.passwordController,
                      hintText: l.password,
                      icon: Icons.lock_outline,
                      obscureText: !provider.isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          provider.isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: provider.togglePasswordVisibility,
                      ),
                      focusNode: provider.passwordFocusNode,
                      errorText: provider.passwordError,
                      onChanged: (value) => provider.setPassword(value),
                    ),

                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        child: Text(
                          l.forgotPassword,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    WideButton(
                      text: l.login,
                      isDisabled: provider.isLoading,
                      onPressed: () => provider.validateForm(context),
                      isLoading: provider.isLoading,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l.dontHaveAccount),
                          const SizedBox(width: 5),
                          InkwellWithOpacity(
                            onTap: () {
                              NavigationUtils.push(context, RegisterScreen());
                            },
                            child: Text(
                              l.register,
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
