import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/product_model.dart';
import '../../catalog/widgets/product_card_widget.dart';

class FeaturedProductsWidget extends StatelessWidget {
  const FeaturedProductsWidget({super.key, required this.products});
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.featured,
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.push(AppRoutes.catalog),
                child: const Text(AppStrings.seeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (_, i) => SizedBox(
              width: 160,
              child: ProductCardWidget(product: products[i]),
            ),
          ),
        ),
      ],
    );
  }
}