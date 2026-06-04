import 'dart:convert';
import '../datasources/remote/firestore_datasource.dart';
import '../datasources/local/local_cache_datasource.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'package:ecommerce_movil/core/constants/firebase_constants.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? categoryId});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<CategoryModel>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final FirestoreDatasource firestoreDatasource;
  final LocalCacheDatasource localCache;

  ProductRepositoryImpl({
    required this.firestoreDatasource,
    required this.localCache,
  });

  @override
  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    try {
      final products =
          await firestoreDatasource.getProducts(categoryId: categoryId);
      // Guardar en caché local
      await localCache.saveString(
        FirebaseConstants.cachedProductsKey,
        jsonEncode(products.map((p) => p.toMap()).toList()),
      );
      return products;
    } catch (e) {
      // Fallback a caché offline
      final raw = localCache.getString(FirebaseConstants.cachedProductsKey);
      if (raw != null) {
        // Retorna lista vacía con datos en caché básica
        // Para datos completos se necesita Hive con todos los campos
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() =>
      firestoreDatasource.getFeaturedProducts();

  @override
  Future<List<CategoryModel>> getCategories() =>
      firestoreDatasource.getCategories();
}