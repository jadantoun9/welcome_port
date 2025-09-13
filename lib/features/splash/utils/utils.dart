import 'package:welcome_port/core/helpers/singletons.dart';

void setUpdateShown(String version) {
  Singletons.sharedPref.setString("last_update_shown", version);
}

bool checkIfUpdateShown(String version) {
  final lastUpdateShown = Singletons.sharedPref.getString("last_update_shown");
  return lastUpdateShown == version;
}

bool isUpdateAvailable({
  required String appVersion,
  required String updateVersion,
}) {
  List<int> appParts = appVersion.split('.').map(int.parse).toList();
  List<int> updateParts = updateVersion.split('.').map(int.parse).toList();
  // Ensure both lists have the same length by padding with zeros
  int maxLength =
      appParts.length > updateParts.length
          ? appParts.length
          : updateParts.length;

  while (appParts.length < maxLength) {
    appParts.add(0);
  }
  while (updateParts.length < maxLength) {
    updateParts.add(0);
  }

  for (int i = 0; i < maxLength; i++) {
    if (updateParts[i] > appParts[i]) return true;
    if (updateParts[i] < appParts[i]) return false;
  }
  return false;
}
