import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/repositories/notification_repository.dart';
import '../core/constants/firebase_constants.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  NotificationProvider({required this.notificationRepository});

  List<RemoteMessage> _messages = [];
  bool _isSubscribedToOffers = true;
  bool _isSubscribedToNewProducts = false;
  bool _isSubscribedToPromotions = false;

  List<RemoteMessage> get messages => _messages;
  bool get isSubscribedToOffers => _isSubscribedToOffers;
  bool get isSubscribedToNewProducts => _isSubscribedToNewProducts;
  bool get isSubscribedToPromotions => _isSubscribedToPromotions;
  int get unreadCount => _messages.length;

  Future<void> initialize() async {
    await notificationRepository.initialize();

    // Escuchar mensajes en foreground
    notificationRepository.onMessage.listen((message) {
      _messages.insert(0, message);
      notifyListeners();
    });

    // Escuchar cuando se abre la app desde una notificación
    notificationRepository.onMessageOpenedApp.listen((message) {
      // TODO: Navegar a la ruta indicada en message.data['route']
      debugPrint('Notification opened: ${message.notification?.title}');
    });
  }

  Future<void> toggleOffers(bool value) async {
    _isSubscribedToOffers = value;
    if (value) {
      await notificationRepository
          .subscribeToTopic(FirebaseConstants.offersTopicKey);
    } else {
      await notificationRepository
          .unsubscribeFromTopic(FirebaseConstants.offersTopicKey);
    }
    notifyListeners();
  }

  Future<void> toggleNewProducts(bool value) async {
    _isSubscribedToNewProducts = value;
    if (value) {
      await notificationRepository
          .subscribeToTopic(FirebaseConstants.newProductsTopicKey);
    } else {
      await notificationRepository
          .unsubscribeFromTopic(FirebaseConstants.newProductsTopicKey);
    }
    notifyListeners();
  }

  Future<void> togglePromotions(bool value) async {
    _isSubscribedToPromotions = value;
    if (value) {
      await notificationRepository
          .subscribeToTopic(FirebaseConstants.promotionsTopicKey);
    } else {
      await notificationRepository
          .unsubscribeFromTopic(FirebaseConstants.promotionsTopicKey);
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}