import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/analytics/facebook_analytics_engine.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/social_login_section.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/features/forgot_password/forgot_password_screen.dart';
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
    FacebookAnalyticsEngine.logPageView(pageName: 'Login');
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
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: provider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add padding at top to account for header
                    const SizedBox(height: 175),
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
                    if (provider.apiError != null)
                      ErrorDisplay(
                        message: provider.apiError!,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),

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
                          NavigationUtils.push(context, ForgotPasswordScreen());
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
                      onPressed:
                          () => provider.validateForm(context, sharedProvider),
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
          ),
          // Header overlay
          Positioned(top: 0, left: 0, right: 0, child: AuthHeader()),
        ],
      ),
    );
  }
}
