import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/remote/firebase_auth_datasource.dart';
import 'data/datasources/remote/firestore_datasource.dart';
import 'data/datasources/remote/firebase_storage_datasource.dart';
import 'data/datasources/remote/stripe_datasource.dart';
import 'data/datasources/local/local_cache_datasource.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/repositories/notification_repository.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // --- Datasources ---
  sl.registerLazySingleton<FirebaseAuthDatasource>(
    () => FirebaseAuthDatasourceImpl(),
  );
  sl.registerLazySingleton<FirestoreDatasource>(
    () => FirestoreDatasourceImpl(),
  );
  sl.registerLazySingleton<FirebaseStorageDatasource>(
    () => FirebaseStorageDatasourceImpl(),
  );
  sl.registerLazySingleton<StripeDatasource>(
    () => StripeDatasourceImpl(),
  );
  sl.registerLazySingleton<LocalCacheDatasource>(
    () => LocalCacheDatasourceImpl(prefs: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDatasource: sl(),
      localCache: sl(),
    ),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      firestoreDatasource: sl(),
      localCache: sl(),
    ),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localCache: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(firestoreDatasource: sl()),
  );
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(storageDatasource: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

  // --- Providers ---
  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => ProductProvider(productRepository: sl()));
  sl.registerFactory(() => CartProvider(cartRepository: sl()));
  sl.registerFactory(() => OrderProvider(
        orderRepository: sl(),
        stripeDatasource: sl(),
      ));
  sl.registerFactory(() => NotificationProvider(
        notificationRepository: sl(),
      ));
  sl.registerFactory(() => ThemeProvider(prefs: sl()));
}