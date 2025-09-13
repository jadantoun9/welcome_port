import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/core/widgets/loader.dart';

class WideButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? borderRadius;
  final bool isDisabled;
  final IconData? icon;
  final Color? borderColor;
  final bool outlined;
  final double? verticalPadding;
  final int? textSize;

  const WideButton({
    super.key,
    required this.text,
    this.bgColor,
    this.textColor,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius,
    this.isDisabled = false,
    this.icon,
    this.borderColor,
    this.outlined = false,
    this.verticalPadding,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkwellWithOpacity(
      onTap: () {
        if (isDisabled || isLoading) {
          return;
        }
        onPressed();
      },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Container(
          height: 52,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 12),
          decoration: BoxDecoration(
            color:
                outlined
                    ? Colors.transparent
                    : (bgColor ?? AppColors.primaryColor),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            border:
                outlined
                    ? Border.all(color: borderColor ?? Colors.grey, width: 1)
                    : null,
          ),
          child: Center(
            child:
                isLoading
                    ? Loader()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color:
                                outlined
                                    ? (textColor ?? Colors.black)
                                    : (textColor ?? Colors.white),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color:
                                outlined
                                    ? (textColor ?? Colors.black)
                                    : (textColor ?? Colors.white),
                            fontSize: textSize?.toDouble() ?? 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
