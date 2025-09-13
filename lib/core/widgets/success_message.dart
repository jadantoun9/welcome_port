import 'package:flutter/material.dart';

/// Shows a success message with a green background and check icon.
///
/// [context] - The BuildContext to show the SnackBar in.
/// [message] - The message to display in the SnackBar.
/// [duration] - Optional duration to show the SnackBar, defaults to 3 seconds.
void showSuccessMessage({
  required BuildContext context,
  required String message,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(10),
    ),
  );
}
