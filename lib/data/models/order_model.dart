import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, paid, shipped, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        productId: d['productId'] ?? '',
        productName: d['productName'] ?? '',
        price: (d['price'] ?? 0).toDouble(),
        quantity: d['quantity'] ?? 1,
        imageUrl: d['imageUrl'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final String shippingAddress;
  final String? stripePaymentIntentId;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.stripePaymentIntentId,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      total: (d['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: d['shippingAddress'] ?? '',
      stripePaymentIntentId: d['stripePaymentIntentId'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'status': status.name,
        'shippingAddress': shippingAddress,
        'stripePaymentIntentId': stripePaymentIntentId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}