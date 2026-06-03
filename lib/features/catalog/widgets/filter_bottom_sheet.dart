import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _sortBy = 'relevance';
  RangeValues _priceRange = const RangeValues(0, 5000);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: scrollCtrl,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.filters,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            Text(AppStrings.sortBy,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _SortChip(
                    label: 'Relevancia',
                    value: 'relevance',
                    selected: _sortBy,
                    onTap: (v) => setState(() => _sortBy = v)),
                _SortChip(
                    label: 'Precio: menor',
                    value: 'price_asc',
                    selected: _sortBy,
                    onTap: (v) => setState(() => _sortBy = v)),
                _SortChip(
                    label: 'Precio: mayor',
                    value: 'price_desc',
                    selected: _sortBy,
                    onTap: (v) => setState(() => _sortBy = v)),
                _SortChip(
                    label: 'Mejor valorados',
                    value: 'rating',
                    selected: _sortBy,
                    onTap: (v) => setState(() => _sortBy = v)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Rango de precio',
                style: theme.textTheme.titleMedium),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              labels: RangeLabels(
                '\$${_priceRange.start.toInt()}',
                '\$${_priceRange.end.toInt()}',
              ),
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _priceRange = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: aplicar filtros al provider
                  Navigator.pop(context);
                },
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}