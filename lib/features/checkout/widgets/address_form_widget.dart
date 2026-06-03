import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';

class AddressFormWidget extends StatelessWidget {
  const AddressFormWidget({
    super.key,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
  });

  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.shippingAddress, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Calle y número',
          hint: 'Ej. Av. Principal 123',
          controller: addressCtrl,
          prefixIcon: Icons.location_on_outlined,
          validator: Validators.required,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                label: 'Ciudad',
                hint: 'Ej. Guadalajara',
                controller: cityCtrl,
                validator: Validators.required,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'C.P.',
                hint: '45000',
                controller: zipCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.minLength(v, 4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}