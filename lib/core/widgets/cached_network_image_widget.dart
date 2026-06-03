import 'package:flutter/material.dart';
import '../utils/image_cache_helper.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  const CachedNetworkImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ImageCacheHelper.network(
      url,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
    );
  }
}