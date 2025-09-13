
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:welcome_port/core/connection/network_error_screen.dart';
import 'package:welcome_port/features/splash/splash_screen.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _isErrorDisplayed = false;
  bool _isAppReady = false;

  void setAppReady() {
    _isAppReady = true;
  }

  @override
  void onInit() {
    super.onInit();
    checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(updateConnectivityStatus);
  }

  Future<void> checkInitialConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    updateConnectivityStatus(result);
  }

  updateConnectivityStatus(ConnectivityResult connectivityResult) {
    if (!_isAppReady) return; // Don't navigate if app isn't ready

    if (connectivityResult == ConnectivityResult.none) {
      if (!_isErrorDisplayed) {
        _isErrorDisplayed = true;
        Get.offAll(() => const NetworkErrorScreen());
      }
    } else {
      if (_isErrorDisplayed) {
        Get.offAll(() => const SplashScreen());
        _isErrorDisplayed = false;
      }
    }
  }
}
