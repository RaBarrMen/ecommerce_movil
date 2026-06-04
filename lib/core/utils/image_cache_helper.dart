import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ImageCacheHelper {
  ImageCacheHelper._();

  /// Widget con caché offline + shimmer + fallback
  static Widget network(
    String? url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final image = CachedNetworkImage(
      imageUrl: url ?? '',
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _shimmer(width: width, height: height),
      errorWidget: (_, __, ___) => _fallback(width: width, height: height),
      fadeInDuration: const Duration(milliseconds: 300),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  static Widget _shimmer({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.shimmerBase,
            AppColors.shimmerHighlight,
            AppColors.shimmerBase,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  static Widget _fallback({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.primaryLight,
      child: const Icon(Icons.image_not_supported_outlined,
          color: AppColors.textHint, size: 32),
    );
  }
}