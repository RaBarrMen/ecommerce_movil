import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 100, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}