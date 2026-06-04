import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/catalog/screens/catalog_screen.dart';
import '../../features/product_detail/screens/product_detail_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/payment/screens/payment_screen.dart';
import '../../features/payment/screens/payment_success_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../data/models/product_model.dart';

// Named routes
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String catalog = '/catalog';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final onboardingDone = authProvider.onboardingDone;
      final path = state.matchedLocation;

      if (!onboardingDone && path != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      if (!isLoggedIn &&
          path != AppRoutes.login &&
          path != AppRoutes.onboarding) {
        return AppRoutes.login;
      }
      if (isLoggedIn && path == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (_, __) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return CatalogScreen(categoryFilter: category);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final total = state.extra as double;
          return PaymentScreen(total: total);
        },
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        builder: (_, __) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
}