import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final bool contain;
  final Color? color;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.contain = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      color: color,
      colorBlendMode: BlendMode.modulate,
      fit: contain ? BoxFit.contain : BoxFit.cover,
      fadeInDuration: const Duration(seconds: 1),
      placeholder: (context, url) => const Center(
        child: CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
