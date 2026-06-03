import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: cart.clearCart,
                    child: const Text('Vaciar',
                        style: TextStyle(color: AppColors.error)),
                  ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(AppAssets.lottieEmpty, width: 180),
                  const SizedBox(height: 16),
                  Text(AppStrings.emptyCart,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.catalog),
                    child: const Text('Ver productos'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      CartItemTile(item: cart.items[i]),
                ),
              ),
              CartSummaryWidget(
                subtotal: cart.subtotal,
                total: cart.total,
                onCheckout: () => context.push(AppRoutes.checkout),
              ),
            ],
          );
        },
      ),
    );
  }
}