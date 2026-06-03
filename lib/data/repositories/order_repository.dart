import '../datasources/remote/firestore_datasource.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Future<String> createOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
}

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreDatasource firestoreDatasource;
  OrderRepositoryImpl({required this.firestoreDatasource});

  @override
  Future<String> createOrder(OrderModel order) =>
      firestoreDatasource.createOrder(order);

  @override
  Future<List<OrderModel>> getUserOrders(String userId) =>
      firestoreDatasource.getUserOrders(userId);
}