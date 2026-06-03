import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/cached_network_image_widget.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.read<CartProvider>();
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => cart.removeItem(item.product.id),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CachedNetworkImageWidget(
                url: item.product.imageUrls.isNotEmpty
                    ? item.product.imageUrls.first
                    : null,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.product.effectivePrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              // Quantity stepper
              Row(
                children: [
                  _StepBtn(
                    icon: Icons.remove,
                    onTap: () => cart.updateQuantity(
                        item.product.id, item.quantity - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                        style: theme.textTheme.titleMedium),
                  ),
                  _StepBtn(
                    icon: Icons.add,
                    onTap: () => cart.updateQuantity(
                        item.product.id, item.quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}