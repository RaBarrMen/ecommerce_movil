import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/cart_provider.dart';

class AddToCartBar extends StatelessWidget {
  const AddToCartBar({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Buy now
          Expanded(
            child: OutlinedButton(
              onPressed: product.isInStock
                  ? () async {
                      await context.read<CartProvider>().addItem(product);
                      if (context.mounted) context.push(AppRoutes.cart);
                    }
                  : null,
              child: const Text('Comprar ahora'),
            ),
          ),
          const SizedBox(width: 12),
          // Add to cart
          Expanded(
            child: ElevatedButton.icon(
              onPressed: product.isInStock
                  ? () {
                      context.read<CartProvider>().addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agregado al carrito'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text(AppStrings.addToCart),
            ),
          ),
        ],
      ),
    );
  }
}