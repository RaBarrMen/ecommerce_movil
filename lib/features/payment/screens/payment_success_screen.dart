import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../providers/order_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim =
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderId = context.watch<OrderProvider>().lastOrderId;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated checkmark
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 72,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.paymentSuccess,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.paymentSuccessSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (orderId != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Pedido: #${orderId.substring(0, 8).toUpperCase()}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      // Steps
                      _StepItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Pedido confirmado',
                        done: true,
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'En preparación',
                        done: false,
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'En camino',
                        done: false,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          child: const Text(AppStrings.continueShoppingBtn),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.profile),
                        child: const Text('Ver mis pedidos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.label,
    required this.done,
  });
  final IconData icon;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: done ? AppColors.success.withOpacity(0.12) : AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 18,
              color: done ? AppColors.success : AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: done ? AppColors.success : AppColors.textSecondary,
            fontWeight: done ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        if (done)
          const Icon(Icons.check, color: AppColors.success, size: 16),
      ],
    );
  }
}
