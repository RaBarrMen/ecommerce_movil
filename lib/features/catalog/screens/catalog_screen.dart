import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      // Si ya hay datos cargados y no hay filtro de categoría, no recargar
      // para evitar parpadeos innecesarios al volver con context.go()
      if (p.status == ProductStatus.initial ||
          p.selectedCategoryId != widget.categoryFilter) {
        p.loadByCategory(widget.categoryFilter);
      }
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

    // canPop() es true si hay una ruta anterior en el stack de GoRouter.
    // Cuando se navega con context.push() -> true (muestra flecha atrás)
    // Cuando se navega con context.go()   -> false (sin flecha, es tab raíz)
    final canGoBack = context.canPop();

    return Scaffold(
      appBar: AppBar(
        // Botón de regreso explícito: solo aparece si hay historia navegable
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                tooltip: 'Regresar',
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: false,
        title: widget.categoryFilter != null
            ? Consumer<ProductProvider>(
                builder: (_, p, __) {
                  // Mostrar nombre de categoría si está disponible
                  final cat = p.categories
                      .where((c) => c.id == widget.categoryFilter)
                      .firstOrNull;
                  return Text(cat?.name ?? AppStrings.catalog);
                },
              )
            : const Text(AppStrings.catalog),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtros',
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
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                context.read<ProductProvider>().setSearch(value);
                // Refrescar para mostrar/ocultar el botón de limpiar
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ProductProvider>().setSearch('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Contenido principal
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, p, __) {
                // Cargando
                if (p.status == ProductStatus.loading) {
                  return const LoadingWidget();
                }

                // Error con mensaje informativo
                if (p.status == ProductStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 56, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            p.errorMessage ?? 'Error al cargar productos',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                p.loadByCategory(widget.categoryFilter),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = p.filteredProducts;

                // Sin resultados
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.noProducts,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Grid de productos
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