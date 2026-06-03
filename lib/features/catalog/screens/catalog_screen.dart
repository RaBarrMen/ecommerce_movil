import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.categoryFilter});
  final String? categoryFilter;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.loadByCategory(widget.categoryFilter);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = ResponsiveHelper.productGridColumns(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.catalog),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const FilterBottomSheet(),
              isScrollControlled: true,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: context.read<ProductProvider>().setSearch,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ProductProvider>().setSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, p, __) {
                if (p.status == ProductStatus.loading) {
                  return const LoadingWidget();
                }
                final products = p.filteredProducts;
                if (products.isEmpty) {
                  return Center(
                    child: Text(AppStrings.noProducts,
                        style: Theme.of(context).textTheme.bodyLarge),
                  );
                }
                return GridView.builder(
                  padding: ResponsiveHelper.horizontalPadding(context)
                      .copyWith(top: 12, bottom: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) =>
                      ProductCardWidget(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}