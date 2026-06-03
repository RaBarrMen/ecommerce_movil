import 'dart:convert';
import '../datasources/local/local_cache_datasource.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../../../lib/core/constants/firebase_constants.dart';

abstract class CartRepository {
  List<CartItemModel> loadCart(List<ProductModel> availableProducts);
  Future<void> saveCart(List<CartItemModel> items);
  Future<void> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  final LocalCacheDatasource localCache;
  CartRepositoryImpl({required this.localCache});

  @override
  List<CartItemModel> loadCart(List<ProductModel> availableProducts) {
    final raw = localCache.getString(FirebaseConstants.cartItemsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final result = <CartItemModel>[];
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final product = availableProducts.firstWhere(
        (p) => p.id == map['productId'],
        orElse: () => throw StateError('Product not found'),
      );
      try {
        result.add(CartItemModel.fromMap(map, product));
      } catch (_) {}
    }
    return result;
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((i) => i.toMap()).toList());
    await localCache.saveString(FirebaseConstants.cartItemsKey, encoded);
  }

  @override
  Future<void> clearCart() => localCache.remove(FirebaseConstants.cartItemsKey);
}