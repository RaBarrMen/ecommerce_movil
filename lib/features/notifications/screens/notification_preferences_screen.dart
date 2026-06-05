import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/notification_provider.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temas de Notificación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Elige los temas sobre los que quieres recibir notificaciones:',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              _TopicTile(
                icon: Icons.local_offer,
                title: 'Ofertas',
                subtitle: 'Descuentos y promociones especiales',
                value: provider.isSubscribedToOffers,
                onChanged: (v) => provider.toggleOffers(v),
              ),
              _TopicTile(
                icon: Icons.new_releases,
                title: 'Nuevos productos',
                subtitle: 'Cuando lleguen artículos nuevos al catálogo',
                value: provider.isSubscribedToNewProducts,
                onChanged: (v) => provider.toggleNewProducts(v),
              ),
              _TopicTile(
                icon: Icons.campaign,
                title: 'Promociones',
                subtitle: 'Eventos y campañas especiales',
                value: provider.isSubscribedToPromotions,
                onChanged: (v) => provider.togglePromotions(v),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TopicTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        secondary:
            CircleAvatar(child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
