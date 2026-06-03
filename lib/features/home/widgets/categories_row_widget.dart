import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/category_model.dart';

class CategoriesRowWidget extends StatelessWidget {
  const CategoriesRowWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final void Function(CategoryModel) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.categories,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text(cat.name),
                  backgroundColor: AppColors.primaryLight,
                  labelStyle: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w500),
                  onPressed: () => onCategoryTap(cat),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}