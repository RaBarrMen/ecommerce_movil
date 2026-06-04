import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _methodTile(
          icon: Icons.credit_card,
          title: 'Tarjeta',
          value: 'card',
        ),
        const SizedBox(height: 12),
        _methodTile(
          icon: Icons.account_balance_wallet,
          title: 'Stripe',
          value: 'stripe',
        ),
      ],
    );
  }

  Widget _methodTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: selected,
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
        title: Text(title),
        secondary: Icon(icon),
      ),
    );
  }
}