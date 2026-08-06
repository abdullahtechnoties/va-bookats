import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utilities/colors.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset = 'assets/images/placeholder.png', 
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String? imageUrl;
  final String fallbackAsset; 
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim();
    final child = source == null || source.isEmpty
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: source,
            fit: fit,
            width: width,
            height: height,
            placeholder: (context, url) => ColoredBox(
              color: AppColors.navOutline.withValues(alpha: 0.45),
              child: const Center(
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
            errorWidget: (context, url, error) => _fallback(),
            memCacheWidth: _cacheExtent(context, width),
            memCacheHeight: _cacheExtent(context, height),
          );

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  int? _cacheExtent(BuildContext context, double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite) return null;
    return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
  }

  Widget _fallback() {
    return Image.asset(fallbackAsset, fit: fit, width: width, height: height);
  }
}
