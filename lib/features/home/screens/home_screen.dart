import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/featured_products_widget.dart';
import '../widgets/categories_row_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: _MobileHome(),
      desktop: _DesktopHome(),
    );
  }
}

class _MobileHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: auth.user?.photoUrl != null
                    ? NetworkImage(auth.user!.photoUrl!)
                    : null,
                child: auth.user?.photoUrl == null
                    ? const Icon(Icons.person, size: 18, color: AppColors.primary)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.status == ProductStatus.loading) {
            return const LoadingWidget();
          }
          return RefreshIndicator(
            onRefresh: () => productProvider.loadAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeBannerWidget(),
                  const SizedBox(height: 16),
                  CategoriesRowWidget(
                    categories: productProvider.categories,
                    onCategoryTap: (cat) => context.push(
                      '${AppRoutes.catalog}?category=${cat.id}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeaturedProductsWidget(
                    products: productProvider.featured,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _DesktopHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side rail
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.home_outlined), label: Text('Inicio')),
              NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined), label: Text('Catálogo')),
              NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_outlined), label: Text('Carrito')),
              NavigationRailDestination(
                  icon: Icon(Icons.person_outline), label: Text('Perfil')),
            ],
            selectedIndex: 0,
            onDestinationSelected: (i) {
              const routes = [
                AppRoutes.home,
                AppRoutes.catalog,
                AppRoutes.cart,
                AppRoutes.profile,
              ];
              context.go(routes[i]);
            },
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: CenteredContent(
              child: _MobileHome(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        const routes = [
          AppRoutes.home,
          AppRoutes.catalog,
          AppRoutes.cart,
          AppRoutes.profile,
        ];
        context.go(routes[i]);
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: AppStrings.catalog,
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: cartProvider.itemCount > 0,
            label: Text('${cartProvider.itemCount}'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: cartProvider.itemCount > 0,
            label: Text('${cartProvider.itemCount}'),
            child: const Icon(Icons.shopping_cart),
          ),
          label: AppStrings.cart,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}