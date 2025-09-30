import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error illustration
          SvgPicture.asset(
            'assets/icons/error_state.svg',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          InkwellWithOpacity(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.retry,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
