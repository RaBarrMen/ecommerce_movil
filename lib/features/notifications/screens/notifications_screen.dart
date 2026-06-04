import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.notifications),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Historial'),
              Tab(text: 'Suscripciones'),
            ],
          ),
          actions: [
            Consumer<NotificationProvider>(
              builder: (_, p, __) => p.messages.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: p.clearMessages,
                      child: const Text('Limpiar',
                          style: TextStyle(color: AppColors.error)),
                    ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _HistoryTab(),
            _SubscriptionsTab(),
          ],
        ),
      ),
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (_, provider, __) {
        if (provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.noNotifications,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Las notificaciones recibidas\naparecerán aquí',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final msg = provider.messages[i];
            return NotificationTile(
              title: msg.notification?.title ?? 'Sin título',
              body: msg.notification?.body ?? '',
              topic: msg.from ?? '',
            );
          },
        );
      },
    );
  }
}

// ── Subscriptions Tab ──────────────────────────────────────────────────────────

class _SubscriptionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (_, provider, __) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Activa los temas que te interesen para recibir notificaciones personalizadas.',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Temas disponibles',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _TopicTile(
              icon: Icons.local_offer_rounded,
              title: 'Ofertas',
              subtitle: 'Descuentos y promociones exclusivas',
              value: provider.isSubscribedToOffers,
              onChanged: provider.toggleOffers,
            ),
            const SizedBox(height: 8),
            _TopicTile(
              icon: Icons.new_releases_outlined,
              title: 'Nuevos productos',
              subtitle: 'Entérate de los lanzamientos más recientes',
              value: provider.isSubscribedToNewProducts,
              onChanged: provider.toggleNewProducts,
            ),
            const SizedBox(height: 8),
            _TopicTile(
              icon: Icons.campaign_outlined,
              title: 'Promociones',
              subtitle: 'Eventos especiales y temporadas',
              value: provider.isSubscribedToPromotions,
              onChanged: provider.togglePromotions,
            ),
          ],
        );
      },
    );
  }
}

// ── Topic Tile ─────────────────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryLight
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: value ? AppColors.primary : AppColors.border,
          width: value ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: value ? Colors.white : AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value ? AppColors.primary : null)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: (v) => onChanged(v),
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
