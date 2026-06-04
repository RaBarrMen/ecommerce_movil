import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/product_model.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/add_to_cart_bar.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        ProductImageGallery(imageUrls: product.imageUrls),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.categoryName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(product.name,
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        // Price + rating
                        Row(
                          children: [
                            Text(
                              '\$${product.effectivePrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textHint,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                            const Spacer(),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(AppStrings.description,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(product.description,
                            style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 20),
                        // Stock indicator
                        Row(
                          children: [
                            Icon(
                              product.isInStock
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: product.isInStock
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.isInStock
                                  ? '${product.stock} en existencia'
                                  : AppStrings.outOfStock,
                              style: TextStyle(
                                color: product.isInStock
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AddToCartBar(product: product),
            ),
          ],
        ),
      ),
    );
  }
}