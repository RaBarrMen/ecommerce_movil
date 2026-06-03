import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/credit_card_form_widget.dart';
import '../widgets/payment_method_selector.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.total});
  final double total;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _selectedMethod = 'card';

  Future<void> _pay() async {
    setState(() => _isProcessing = true);

    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      final clientSecret = orderProvider.paymentClientSecret;
      if (clientSecret == null) throw Exception('No payment intent found');

      // Inicializar sheet de pago de Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppStrings.appName,
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      );

      // Mostrar sheet
      await Stripe.instance.presentPaymentSheet();

      // Confirmar pedido en Firestore
      if (mounted) {
        await orderProvider.placeOrder(
          userId: authProvider.user!.uid,
          items: cartProvider.items,
          total: widget.total,
          shippingAddress: 'Dirección del checkout',
          paymentIntentId: clientSecret,
        );
        await cartProvider.clearCart();
        if (mounted) context.go(AppRoutes.paymentSuccess);
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago cancelado: ${e.error.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.payment)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total a pagar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total a pagar',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Selector de método de pago
            Text(AppStrings.paymentMethod,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            PaymentMethodSelector(
              selected: _selectedMethod,
              onChanged: (m) => setState(() => _selectedMethod = m),
            ),
            const SizedBox(height: 28),
            // Formulario de tarjeta (visual - Stripe maneja el sheet real)
            if (_selectedMethod == 'card') ...[
              Text('Datos de tarjeta', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              const CreditCardFormWidget(),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stripeBlue,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_outline, size: 18,
                              color: Colors.white),
                          SizedBox(width: 8),
                          Text(AppStrings.payNow,
                              style: TextStyle(color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 14,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Pago seguro con Stripe',
                      style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}