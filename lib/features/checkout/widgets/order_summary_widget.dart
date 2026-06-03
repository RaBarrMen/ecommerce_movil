import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/cached_network_image_widget.dart';
import '../../../data/models/cart_item_model.dart';

class OrderSummaryWidget extends StatelessWidget {
  const OrderSummaryWidget({
    super.key,
    required this.cartItems,
    required this.total,
  });

  final List<CartItemModel> cartItems;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen del pedido', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...cartItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CachedNetworkImageWidget(
                          url: item.product.imageUrls.isNotEmpty
                              ? item.product.imageUrls.first
                              : null,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: theme.textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'x${item.quantity}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.total,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}