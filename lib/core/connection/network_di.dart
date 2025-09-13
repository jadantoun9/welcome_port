import 'package:get/get.dart';
import 'package:welcome_port/core/connection/network_controller.dart';

class NetworkDi {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
