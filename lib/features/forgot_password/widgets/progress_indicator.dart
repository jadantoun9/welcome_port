import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final int currentStep;
  const ProgressIndicatorWidget({super.key, required this.currentStep});

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          _buildStep(
            step: 1,
            label: AppLocalizations.of(context)!.email,
            isCompleted: widget.currentStep > 0,
            isActive: widget.currentStep == 0,
          ),
          Expanded(child: _buildSeperator()),
          _buildStep(
            step: 2,
            label: AppLocalizations.of(context)!.verify,
            isCompleted: widget.currentStep > 1,
            isActive: widget.currentStep == 1,
          ),
          Expanded(child: _buildSeperator()),
          _buildStep(
            step: 3,
            label: AppLocalizations.of(context)!.reset,
            isCompleted: widget.currentStep > 2,
            isActive: widget.currentStep == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSeperator() {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: widget.currentStep > 2 ? AppColors.primaryColor : Colors.grey[400],
    );
  }

  Widget _buildStep({
    required int step,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : isActive
                    ? AppColors.primaryColor
                    : Colors.grey[300],
          ),
          child: Center(
            child:
                isCompleted
                    ? Icon(Icons.check, color: AppColors.primaryColor, size: 20)
                    : Text(
                      step.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color:
                isCompleted || isActive
                    ? AppColors.primaryColor
                    : AppColors.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
