import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../providers/notification_provider.dart';
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
      mobile: const _MobileHome(),
      desktop: const _DesktopHome(),
    );
  }
}

// ── Vista mobile ──────────────────────────────────────────────────────────────
// NOTA: Ya NO incluye BottomNavigationBar — ahora lo gestiona el ShellRoute
// en app_router.dart para que aparezca en todas las pestañas sin duplicarse.

class _MobileHome extends StatelessWidget {
  const _MobileHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Botón de notificaciones con badge
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
          // Avatar del usuario
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
                    ? const Icon(Icons.person,
                        size: 18, color: AppColors.primary)
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
                    // push (no go) para apilar sobre el home y poder regresar
                    onCategoryTap: (cat) => context.push(
                      '${AppRoutes.catalog}?category=${cat.id}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeaturedProductsWidget(products: productProvider.featured),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      // BottomNav eliminado — lo provee _ShellScaffold en app_router.dart
    );
  }
}

// ── Vista desktop ─────────────────────────────────────────────────────────────
// NavigationRail con selectedIndex correcto según la ruta actual.

class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  static const _tabRoutes = [
    AppRoutes.home,
    AppRoutes.catalog,
    AppRoutes.cart,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    // Calcular índice activo a partir de la ruta actual
    final location = GoRouterState.of(context).matchedLocation;
    int selectedIndex = 0;
    for (var i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: Text('Catálogo'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Carrito'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Perfil'),
              ),
            ],
            selectedIndex: selectedIndex, // ← ya no está hardcodeado en 0
            onDestinationSelected: (i) => context.go(_tabRoutes[i]),
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _MobileHome(),
          ),
        ],
      ),
    );
  }
}