import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/loader.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmButtonText = 'Confirm',
  String cancelButtonText = 'Cancel',
  ValueNotifier<String>? errorNotifier,
  Future<bool> Function()? onConfirm,
}) async {
  bool isLoading = false;
  final localErrorNotifier = errorNotifier ?? ValueNotifier<String>('');

  Navigator.of(context).popUntil((route) => route is! PopupRoute);

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Function for cancel button
          void handleCancel() {
            Navigator.pop(context, false);
          }

          // Function for confirm button
          void handleConfirm() async {
            if (onConfirm != null) {
              setState(() {
                isLoading = true;
              });

              final result = await onConfirm();

              setState(() {
                isLoading = false;
              });

              if (context.mounted && result) {
                Navigator.pop(context, true);
              }
            } else {
              Navigator.pop(context, true);
            }
          }

          return ValueListenableBuilder<String>(
            valueListenable: localErrorNotifier,
            builder: (context, currentErrorMessage, _) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                        child: const Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cancel Button
                          SizedBox(
                            width: 120, // Fixed width
                            child: InkwellWithOpacity(
                              onTap: isLoading ? () {} : handleCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cancelButtonText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Confirm Button
                          SizedBox(
                            width: 120, // Fixed width
                            child: InkwellWithOpacity(
                              onTap: isLoading ? () {} : handleConfirm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    isLoading
                                        ? const Loader()
                                        : Text(
                                          confirmButtonText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentErrorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            currentErrorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );

  // Clean up the notifier if we created it locally
  if (errorNotifier == null) {
    localErrorNotifier.dispose();
  }

  return result ?? false;
}
