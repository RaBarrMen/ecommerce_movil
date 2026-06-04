import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.photoUrl,
    this.radius = 36,
    this.isLoading = false,
  });

  final String? photoUrl;
  final double radius;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: radius * 2,
              height: radius * 2,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: AppColors.primaryLight,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          : CircleAvatar(
              key: ValueKey(photoUrl ?? 'no_photo'),
              radius: radius,
              backgroundColor: AppColors.primaryLight,
              child: photoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photoUrl!,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: radius,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: radius,
                    ),
            ),
    );
  }
}
