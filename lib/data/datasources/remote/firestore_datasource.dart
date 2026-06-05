import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../../core/constants/firebase_constants.dart';

abstract class FirestoreDatasource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<List<ProductModel>> getProducts({String? categoryId});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<CategoryModel>> getCategories();
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(String productId, Map<String, dynamic> data);
  Future<void> deleteProduct(String productId);
  Future<String> createOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markNotificationRead(String userId, String notificationId);
}

class FirestoreDatasourceImpl implements FirestoreDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  @override
  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    Query query = _db
        .collection(FirebaseConstants.productsCollection)
        .where('isActive', isEqualTo: true);
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final snapshot = await _db
        .collection(FirebaseConstants.productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db
        .collection(FirebaseConstants.categoriesCollection)
        .orderBy('order')
        .get();
    return snapshot.docs.map((d) => CategoryModel.fromFirestore(d)).toList();
  }

  // ── CRUD Productos (Admin) ─────────────────────────────────────────────────

  @override
  Future<void> createProduct(ProductModel product) async {
    await _db
        .collection(FirebaseConstants.productsCollection)
        .add(product.toMap()..['createdAt'] = FieldValue.serverTimestamp());
  }

  @override
  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(FirebaseConstants.productsCollection)
        .doc(productId)
        .update(data);
  }

  /// Soft delete: marca isActive = false en lugar de borrar el documento.
  @override
  Future<void> deleteProduct(String productId) async {
    await _db
        .collection(FirebaseConstants.productsCollection)
        .doc(productId)
        .update({'isActive': false});
  }

  // ── Pedidos ────────────────────────────────────────────────────────────────

  @override
  Future<String> createOrder(OrderModel order) async {
    final ref = await _db
        .collection(FirebaseConstants.ordersCollection)
        .add(order.toMap());
    return ref.id;
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _db
        .collection(FirebaseConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }

  // ── Notificaciones ─────────────────────────────────────────────────────────

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final snapshot = await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.notificationsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => NotificationModel.fromFirestore(d))
        .toList();
  }

  @override
  Future<void> markNotificationRead(
      String userId, String notificationId) async {
    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }
}
