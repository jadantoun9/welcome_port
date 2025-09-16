import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/confirmation_dialog.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/selection_dialog.dart';
import 'package:welcome_port/features/login/login_screen.dart';
import 'package:welcome_port/features/more/more_service.dart';
import 'package:welcome_port/features/profile/profile_screen.dart';
import 'package:welcome_port/features/splash/splash_screen.dart';

class MoreProvider extends ChangeNotifier {
  final moreService = MoreService();
  String? error;
  bool isLoading = false;

  void _setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void _setError(String err) {
    error = err;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void onConfirmLogout(BuildContext context, SharedProvider sharedProvider) {
    final l10n = AppLocalizations.of(context)!;

    // Create a ValueNotifier that will update when the provider's error changes
    final errorNotifier = ValueNotifier<String>(error ?? '');

    // Function to update the error notifier when provider changes
    void updateErrorNotifier() {
      errorNotifier.value = error ?? '';
    }

    // Add the listener
    addListener(updateErrorNotifier);

    showConfirmationDialog(
      context: context,
      title: l10n.logout,
      message: l10n.areYouSureLogout,
      confirmButtonText: l10n.confirm,
      errorNotifier: errorNotifier,
      onConfirm: () async {
        final result = await _logOut(sharedProvider, context);
        if (result && context.mounted) {
          // The dialog will be automatically closed by the confirmation dialog
          // when we return true, and then we'll navigate to splash screen
          return true;
        }
        return false;
      },
    ).then((confirmed) {
      // Clean up when dialog is closed
      removeListener(updateErrorNotifier);
      errorNotifier.dispose();

      // If logout was successful, navigate to splash screen
      if (confirmed && context.mounted) {
        NavigationUtils.clearAndPush(context, const SplashScreen());
      }

      // Clear any errors
      clearError();
    });
  }

  Future<bool> _logOut(
    SharedProvider sharedProvider,
    BuildContext context,
  ) async {
    _setLoading(true);
    clearError();

    final result = await moreService.logout();

    var success = false;
    result.fold(
      (error) => {_setError(error), success = false},
      (loggedOut) => {
        sharedProvider.setCustomer(null),
        success = true,
        sharedProvider.setSelectedIndex(0),
      },
    );
    _setLoading(false);
    return success;
  }

  void onTopBoxTap(BuildContext context, SharedProvider sharedProvider) {
    if (sharedProvider.customer == null) {
      NavigationUtils.push(context, const LoginScreen());
    } else {
      NavigationUtils.push(context, const ProfileScreen());
    }
  }

  void showLanguageDialog(
    BuildContext context,
    SharedProvider sharedProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final languages =
        sharedProvider.setting?.languages.isNotEmpty == true
            ? sharedProvider.setting!.languages
                .map(
                  (lang) => SelectionItem(
                    value: lang.code,
                    title: lang.name,
                    icon: lang.image,
                  ),
                )
                .toList()
            : List<SelectionItem>.empty();

    final selectedValue = await showSelectionDialog(
      context: context,
      title: l10n.selectLanguage,
      items: languages,
      currentValue: sharedProvider.locale.languageCode,
    );

    if (selectedValue != null) {
      sharedProvider.changeLocale(Locale(selectedValue));
    }
  }

  void showCurrencyDialog(
    BuildContext context,
    SharedProvider sharedProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final currencies =
        sharedProvider.setting?.currencies.isNotEmpty == true
            ? sharedProvider.setting!.currencies
                .map(
                  (currency) => SelectionItem(
                    value: currency.code,
                    title: currency.name,
                    icon: currency.image,
                  ),
                )
                .toList()
            : List<SelectionItem>.empty();

    final selectedValue = await showSelectionDialog(
      context: context,
      title: l10n.selectCurrency,
      items: currencies,
      currentValue: sharedProvider.currency,
    );

    if (selectedValue != null) {
      sharedProvider.changeCurrency(selectedValue);
    }
  }
}
