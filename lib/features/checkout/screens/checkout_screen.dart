import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../widgets/address_form_widget.dart';
import '../widgets/order_summary_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _proceed() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.preparePayment(totalAmount: cart.total);
    if (mounted && orderProvider.status == OrderStatus2.success) {
      context.push(AppRoutes.payment, extra: cart.total);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddressFormWidget(
                addressCtrl: _addressCtrl,
                cityCtrl: _cityCtrl,
                zipCtrl: _zipCtrl,
              ),
              const SizedBox(height: 24),
              OrderSummaryWidget(cartItems: cart.items, total: cart.total),
              const SizedBox(height: 32),
              Consumer<OrderProvider>(
                builder: (_, orderProv, __) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: orderProv.status == OrderStatus2.loading
                        ? null
                        : _proceed,
                    child: orderProv.status == OrderStatus2.loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5)
                        : const Text(AppStrings.placeOrder),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}