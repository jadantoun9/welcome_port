import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';

Future<File?> selectImage({
  ImageSource source = ImageSource.gallery,
  required BuildContext context,
}) async {
  try {
    final ImagePicker picker = ImagePicker();

    // Set platform-specific options for iOS
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
      requestFullMetadata: false, // Sometimes helps with iOS JPEG issues
    );

    if (image != null) {
      final file = File(image.path);
      final extension = image.path.split('.').last;
      debugPrint('File extension: $extension');
      return file;
    }
    return null;
  } catch (e, stackTrace) {
    debugPrint('Error selecting image: $e');
    debugPrint('Stack trace: $stackTrace');
    if (context.mounted) {
      showErrorDialog(
        context: context,
        title: AppLocalizations.of(context)!.failedToSelectImage,
        message: AppLocalizations.of(context)!.chooseAnotherImageType,
      );
    }
    return null;
  }
}
