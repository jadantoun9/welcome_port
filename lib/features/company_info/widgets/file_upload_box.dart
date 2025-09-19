import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FileUploadBox extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool isLoading;
  final String? code;
  final String? imagePath;
  final String? initialImageUrl;
  final Function? onClear;
  final String? errorText;
  final bool showInitialImage;

  const FileUploadBox({
    super.key,
    required this.title,
    required this.onTap,
    required this.isLoading,
    this.code,
    this.imagePath,
    this.initialImageUrl,
    this.onClear,
    this.errorText,
    this.showInitialImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  errorText != null && errorText != ""
                      ? Colors.red
                      : (code != null ? Colors.grey[300]! : Color(0xFFE5E5E5)),
              width: (code != null || errorText != null) ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Main content
              InkWell(
                onTap: () => onTap(),
                child:
                    isLoading
                        ? const Center(
                          child: Loader(color: AppColors.foregroundColor),
                        )
                        : imagePath != null
                        ? _buildImageView()
                        : initialImageUrl != null &&
                            imagePath == null &&
                            showInitialImage
                        ? _buildInitialImageView()
                        : Center(child: _buildDefaultView(context)),
              ),

              // Clear button
              if ((code != null ||
                      (initialImageUrl != null && showInitialImage)) &&
                  onClear != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => onClear!(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildImageView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.file(
        File(imagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInitialImageView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: CachedNetworkImage(
        imageUrl: initialImageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.foregroundColor,
                strokeWidth: 2,
              ),
            ),
        errorWidget:
            (context, url, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildDefaultView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (code != null)
          const Icon(
            Icons.check_circle,
            size: 40,
            color: AppColors.foregroundColor,
          )
        else
          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 10),
        Text(
          code != null ? AppLocalizations.of(context)!.documentUploaded : title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: code != null ? FontWeight.bold : FontWeight.normal,
            color: code != null ? AppColors.foregroundColor : null,
          ),
        ),
      ],
    );
  }
}
