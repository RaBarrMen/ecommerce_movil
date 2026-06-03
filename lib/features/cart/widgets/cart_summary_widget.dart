import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class CartSummaryWidget extends StatelessWidget {
  const CartSummaryWidget({
    super.key,
    required this.subtotal,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: theme.textTheme.bodyMedium),
              Text('\$${subtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Envío', style: theme.textTheme.bodyMedium),
              const Text('Gratis',
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.total,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text(AppStrings.checkout),
            ),
          ),
        ],
      ),
    );
  }
}