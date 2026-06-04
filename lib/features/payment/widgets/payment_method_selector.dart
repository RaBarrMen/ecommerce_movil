import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MethodTile(
          id: 'card',
          label: 'Tarjeta de crédito/débito',
          icon: Icons.credit_card_rounded,
          subtitle: 'Visa, Mastercard, Amex',
          selected: selected,
          onTap: onChanged,
        ),
        const SizedBox(height: 8),
        _MethodTile(
          id: 'sandbox',
          label: 'Modo Sandbox',
          icon: Icons.science_outlined,
          subtitle: 'Simular pago sin datos reales',
          selected: selected,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.id,
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final String label;
  final IconData icon;
  final String subtitle;
  final String selected;
  final void Function(String) onTap;

  bool get isSelected => selected == id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryLight
            : theme.colorScheme.surface,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => onTap(id),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: isSelected ? Colors.white : AppColors.primary, size: 22),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
        subtitle: Text(subtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 12)),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, key: ValueKey('check'))
              : Icon(Icons.radio_button_unchecked,
                  color: AppColors.textHint, key: const ValueKey('empty')),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
