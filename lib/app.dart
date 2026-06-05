import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// Motor de datos locales — se mantiene para compatibilidad con CartScreen
class LocalCartManager {
  static List<Map<String, dynamic>> items = [];

  static void add(Map<String, dynamic> product) {
    final existing = items.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {},
    );
    if (existing.isEmpty) {
      items.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      });
    } else {
      existing['quantity'] = (existing['quantity'] as int) + 1;
    }
  }

  static double get total =>
      items.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

  static void clear() => items.clear();
}

/// Clase principal de la aplicación.
///
/// CORRECCIÓN CRÍTICA: Se reemplazó MaterialApp(...) por MaterialApp.router(...)
/// para que GoRouter esté disponible en todo el árbol de widgets.
/// Sin esto, cualquier llamada a context.go() o context.push() lanza:
///   AssertionError: No GoRouter found in context
class ShopApp extends StatelessWidget {
  const ShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'ShopApp',
      debugShowCheckedModeBanner: false,

      // Temas desde AppTheme — respeta el modo claro/oscuro del ThemeProvider
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // GoRouter como fuente única de verdad para la navegación
      routerConfig: AppRouter.router,
    );
  }
}