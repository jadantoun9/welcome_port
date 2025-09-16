// Reusable MenuButton widget
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';

class MenuButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String? imagePath;
  final String? networkImagePath;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double? iconPadding;

  const MenuButton({
    super.key,
    this.icon,
    this.svgPath,
    this.imagePath,
    this.networkImagePath,
    this.iconPadding,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : assert(
         icon != null ||
             svgPath != null ||
             imagePath != null ||
             networkImagePath != null,
         'Either icon, svgPath, imagePath, or networkImagePath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return InkwellWithOpacity(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              // padding: const EdgeInsets.all(12),
              height: 41,
              width: 41,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: _buildIcon(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
            Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (svgPath != null) {
      return Padding(
        padding: EdgeInsets.all(iconPadding ?? 8.0),
        child: SvgPicture.asset(
          svgPath!,
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      );
    } else if (imagePath != null) {
      return Padding(
        padding: EdgeInsets.all(iconPadding ?? 8.0),
        child: Image.asset(imagePath!, width: 20, height: 20),
      );
    } else if (networkImagePath != null) {
      if (networkImagePath!.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.all(iconPadding ?? 8.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CustomCachedImage(
            imageUrl: networkImagePath!,
            contain: true,
            color: Colors.black,
          ),
        ),
      );
    } else {
      return Icon(icon!, color: Colors.black, size: 20);
    }
  }
}
