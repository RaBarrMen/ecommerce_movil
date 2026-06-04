import 'package:flutter/material.dart';

class CreditCardFormWidget extends StatelessWidget {
  const CreditCardFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Titular de la tarjeta',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de tarjeta',
            prefixIcon: Icon(Icons.credit_card),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MM/AA',
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}