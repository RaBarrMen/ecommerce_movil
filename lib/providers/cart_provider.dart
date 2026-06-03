import 'package:flutter/material.dart';
import '../data/repositories/cart_repository.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;
  CartProvider({required this.cartRepository});

  List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0, (sum, i) => sum + i.subtotal);

  double get total => subtotal; // Aquí puedes agregar impuestos/envío

  void loadCart(List<ProductModel> products) {
    try {
      _items = cartRepository.loadCart(products);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addItem(ProductModel product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(CartItemModel(product: product));
    }
    await _persist();
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((i) => i.product.id == productId);
    await _persist();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _persist();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await cartRepository.clearCart();
    notifyListeners();
  }

  Future<void> _persist() async {
    await cartRepository.saveCart(_items);
    notifyListeners();
  }
}