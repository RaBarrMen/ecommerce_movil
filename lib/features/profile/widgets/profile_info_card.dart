import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.user});
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información de cuenta', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Nombre',
              value: user!.name.isNotEmpty ? user!.name : '—',
            ),
            const Divider(height: 20),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Correo',
              value: user!.email,
            ),
            if (user!.phone != null) ...[
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: user!.phone!,
              ),
            ],
            if (user!.createdAt != null) ...[
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Miembro desde',
                value: _formatDate(user!.createdAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
