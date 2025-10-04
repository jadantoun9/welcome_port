import 'package:flutter/material.dart';
import 'package:welcome_port/core/analytics/facebook_analytics_engine.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/service/social_login_service.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';

class SocialLoginProvider extends ChangeNotifier {
  bool isAppleLoading = false;
  bool isGoogleLoading = false;
  bool isCancelled = false;
  String? error;

  final service = SocialLoginService();

  void clearError() {
    error = null;
    isCancelled = false;
    notifyListeners();
  }

  void _setIsAppleLoading(bool loading) {
    isAppleLoading = loading;
    notifyListeners();
  }

  void _setIsGoogleLoading(bool loading) {
    isGoogleLoading = loading;
    notifyListeners();
  }

  void setError(String value) {
    error = value;
    notifyListeners();
  }

  void setCancelled() {
    isCancelled = true;
    error = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle(
    BuildContext context,
    SharedProvider sharedProvider,
  ) async {
    _setIsGoogleLoading(true);
    final result = await service.signInWithGoogle();

    if (result.isSuccess) {
      sharedProvider.setCustomer(result.user!);

      // Track successful sign in with Google
      FacebookAnalyticsEngine.logSignIn(method: 'google');

      if (!context.mounted) return;
      _navigateAfterLogin(context, sharedProvider);
    } else if (result.isError) {
      setError(result.error!);
    } else if (result.isCancelled) {
      setCancelled();
    }
    _setIsGoogleLoading(false);
  }

  Future<void> signInWithApple(
    BuildContext context,
    SharedProvider sharedProvider,
  ) async {
    _setIsAppleLoading(true);
    final result = await service.signInWithApple();

    if (result.isSuccess) {
      sharedProvider.setCustomer(result.user!);

      // Track successful sign in with Apple
      FacebookAnalyticsEngine.logSignIn(method: 'apple');

      if (!context.mounted) return;
      _navigateAfterLogin(context, sharedProvider);
    } else if (result.isError) {
      setError(result.error!);
    } else if (result.isCancelled) {
      setCancelled();
    }
    _setIsAppleLoading(false);
  }

  void _navigateAfterLogin(
    BuildContext context,
    SharedProvider sharedProvider,
  ) {
    sharedProvider.setSelectedIndex(0);
    NavigationUtils.clearAndPush(context, const NavScreen());
  }
}
