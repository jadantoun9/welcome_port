import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/service/auth_service.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/features/login/login_screen.dart';
import 'package:welcome_port/features/profile/profile_screen.dart';
import 'package:welcome_port/features/register/register_screen.dart';
import 'package:welcome_port/features/splash/splash_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sharedProvider.customer == null)
                Column(
                  children: [
                    _CustomButton(
                      text: 'Login',
                      onPressed:
                          () => NavigationUtils.push(context, LoginScreen()),
                    ),
                    const SizedBox(height: 16),
                    _CustomButton(
                      text: 'Create Account',
                      onPressed:
                          () => NavigationUtils.push(context, RegisterScreen()),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (sharedProvider.customer != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _CustomButton(
                      text: 'Profile',
                      onPressed:
                          () => NavigationUtils.push(context, ProfileScreen()),
                    ),
                    const SizedBox(height: 16),
                    _CustomButton(
                      text: 'Logout',
                      onPressed: () async {
                        final result = await AuthService.logOut();
                        result.fold(
                          (error) {
                            showErrorDialog(context: context, message: error);
                          },
                          (value) {
                            sharedProvider.setCustomer(null);
                            NavigationUtils.clearAndPush(
                              context,
                              SplashScreen(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
