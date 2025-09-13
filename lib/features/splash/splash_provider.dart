import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/show_update_dialog.dart';
import 'package:welcome_port/features/nav/nav_screen.dart';
import 'package:welcome_port/features/splash/splash_service.dart';
import 'package:welcome_port/features/splash/utils/utils.dart';

class SplashProvider extends ChangeNotifier {
  final SplashService service = SplashService();
  String? error;

  void initialize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData(context);
    });
  }

  void setError(String value) {
    error = value;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<bool> _checkIfCanProceed(BuildContext context) async {
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final l = AppLocalizations.of(context)!;

    OsUpdateModel? updateModel =
        (Platform.isIOS
            ? sharedProvider.setting?.update?.ios
            : sharedProvider.setting?.update?.android);

    if (updateModel == null) {
      return true;
    }

    if (isUpdateAvailable(
      appVersion: Singletons.packageInfo.version,
      updateVersion: updateModel.version,
    )) {
      final isForced = sharedProvider.setting!.update!.force;

      // if update has already been shown, and it is not forced, return true
      if (checkIfUpdateShown(updateModel.version) && !isForced) {
        return true;
      }

      final forceMessage = isForced ? l.pleaseUpdateApp : '';
      await showUpdateDialog(
        context: context,
        message: l.versionAvailable(updateModel.version, forceMessage),
        isForced: isForced,
        url: updateModel.url,
      );

      if (isForced) {
        // For forced updates, keep showing dialog until user updates
        // Return false to prevent proceeding
        return false;
      } else {
        // For non-forced updates, remember user's choice
        setUpdateShown(updateModel.version);
        // User can proceed regardless of their choice (Update Now or Maybe Later)
        return true;
      }
    }
    return true;
  }

  void fetchData(BuildContext context) async {
    final result = await service.getSetting();
    if (!context.mounted) return;

    result.fold((error) => setError(error), (data) async {
      final sharedProvider = Provider.of<SharedProvider>(
        context,
        listen: false,
      );
      sharedProvider.setSetting(data);

      // Keep checking until user can proceed (handles forced updates)
      bool allowToProceed = false;
      while (!allowToProceed && context.mounted) {
        if (!context.mounted) return;
        allowToProceed = await _checkIfCanProceed(context);
        if (!allowToProceed) {
          // Wait a bit before checking again (prevents infinite tight loop)
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (!context.mounted) return;

      NavigationUtils.pushReplacement(context, const NavScreen());
    });
  }
}
