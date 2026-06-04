import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    this.topic = '',
    this.isRead = false,
    this.onTap,
  });

  final String title;
  final String body;
  final String topic;
  final bool isRead;
  final VoidCallback? onTap;

  IconData _topicIcon() {
    if (topic.contains('offer')) return Icons.local_offer_rounded;
    if (topic.contains('product')) return Icons.new_releases_outlined;
    if (topic.contains('promo')) return Icons.campaign_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isRead ? AppColors.primaryLight.withOpacity(0.5) : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _topicIcon(),
            color: isRead ? AppColors.textHint : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
    );
  }
}
