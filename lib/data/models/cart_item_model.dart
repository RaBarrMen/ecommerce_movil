import 'dart:convert';
import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get subtotal => product.effectivePrice * quantity;

  CartItemModel copyWith({int? quantity}) =>
      CartItemModel(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toMap() => {
        'productId': product.id,
        'productName': product.name,
        'price': product.effectivePrice,
        'imageUrl': product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
        'quantity': quantity,
      };

  static CartItemModel fromMap(
      Map<String, dynamic> map, ProductModel product) =>
      CartItemModel(product: product, quantity: map['quantity'] ?? 1);

  String toJson() => jsonEncode(toMap());
}