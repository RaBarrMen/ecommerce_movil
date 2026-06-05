import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // 1. Iniciar enlaces nativos obligatorios
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('PASO 1: WidgetsFlutterBinding OK');

  // 2. Stripe en segundo plano (no bloqueante, no crítico para arrancar)
  try {
    Stripe.publishableKey =
        'pk_test_51TeVEgIUBsWsRn1mDtOQQdA0Iy96y82NjYJXX1mpSYESjseZZeTOMAFNvUh6pImU1xlDjSEOkVbDM8s9ios25Fsz00A7szgcxE';
    await Stripe.instance.applySettings();
    debugPrint('PASO 2: Stripe OK');
  } catch (e, st) {
    debugPrint('⚠️ Stripe omitido: $e');
    debugPrintStack(stackTrace: st);
    // No rethrow — Stripe no es crítico para el arranque
  }

  // 3. Firebase — SIN timeout artificial, exponiendo el error real
  try {
    debugPrint('PASO 3: Iniciando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('PASO 4: Firebase OK');
  } catch (e, st) {
    debugPrint('ERROR CRÍTICO Firebase: $e');
    debugPrintStack(stackTrace: st);
    rethrow; // Si Firebase falla, no tiene sentido continuar
  }

  // 4. Inyección de dependencias — exponiendo el error real
  try {
    debugPrint('PASO 5: Iniciando DI...');
    await di.init();
    debugPrint('PASO 6: DI OK');
  } catch (e, st) {
    debugPrint('ERROR CRÍTICO DI: $e');
    debugPrintStack(stackTrace: st);
    rethrow; // Si DI falla, los providers no existen y la app explota igual
  }

  debugPrint('PASO 7: runApp iniciando...');

  // 5. Arrancar la aplicación con providers lazy
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 8: Creando AuthProvider');
            return di.sl<AuthProvider>();
          },
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 9: Creando ProductProvider');
            return di.sl<ProductProvider>();
          },
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 10: Creando CartProvider');
            return di.sl<CartProvider>();
          },
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 11: Creando OrderProvider');
            return di.sl<OrderProvider>();
          },
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 12: Creando NotificationProvider');
            return di.sl<NotificationProvider>();
          },
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('PASO 13: Creando ThemeProvider');
            return di.sl<ThemeProvider>();
          },
          lazy: true,
        ),
      ],
      child: const ShopApp(),
    ),
  );

  debugPrint('PASO 14: runApp completado');
}