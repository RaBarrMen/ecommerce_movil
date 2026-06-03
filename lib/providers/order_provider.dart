import 'package:flutter/material.dart';
import '../data/repositories/order_repository.dart';
import '../data/datasources/remote/stripe_datasource.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';

enum OrderStatus2 { initial, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository orderRepository;
  final StripeDatasource stripeDatasource;

  OrderProvider({
    required this.orderRepository,
    required this.stripeDatasource,
  });

  OrderStatus2 _status = OrderStatus2.initial;
  List<OrderModel> _orders = [];
  String? _errorMessage;
  String? _lastOrderId;
  String? _paymentClientSecret;

  OrderStatus2 get status => _status;
  List<OrderModel> get orders => _orders;
  String? get errorMessage => _errorMessage;
  String? get lastOrderId => _lastOrderId;
  String? get paymentClientSecret => _paymentClientSecret;

  Future<void> loadOrders(String userId) async {
    _status = OrderStatus2.loading;
    notifyListeners();
    try {
      _orders = await orderRepository.getUserOrders(userId);
      _status = OrderStatus2.success;
    } catch (e) {
      _status = OrderStatus2.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Crea el PaymentIntent de Stripe antes de mostrar la pantalla de pago
  Future<void> preparePayment({
    required double totalAmount,
    String currency = 'mxn',
  }) async {
    _status = OrderStatus2.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final amountInCents = (totalAmount * 100).toInt();
      _paymentClientSecret = await stripeDatasource.createPaymentIntent(
        amountInCents: amountInCents,
        currency: currency,
      );
      _status = OrderStatus2.success;
    } catch (e) {
      _status = OrderStatus2.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required double total,
    required String shippingAddress,
    String? paymentIntentId,
  }) async {
    _status = OrderStatus2.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final order = OrderModel(
        id: '',
        userId: userId,
        items: items
            .map((i) => OrderItem(
                  productId: i.product.id,
                  productName: i.product.name,
                  price: i.product.effectivePrice,
                  quantity: i.quantity,
                  imageUrl: i.product.imageUrls.isNotEmpty
                      ? i.product.imageUrls.first
                      : '',
                ))
            .toList(),
        total: total,
        status: OrderStatus.paid,
        shippingAddress: shippingAddress,
        stripePaymentIntentId: paymentIntentId,
        createdAt: DateTime.now(),
      );
      _lastOrderId = await orderRepository.createOrder(order);
      _status = OrderStatus2.success;
    } catch (e) {
      _status = OrderStatus2.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _status = OrderStatus2.initial;
    _errorMessage = null;
    _paymentClientSecret = null;
    notifyListeners();
  }
}