import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/repositories/notification_repository.dart';
import '../core/constants/firebase_constants.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  NotificationProvider({required this.notificationRepository});

  final List<RemoteMessage> _messages = [];
  bool _isSubscribedToOffers = true;
  bool _isSubscribedToNewProducts = false;
  bool _isSubscribedToPromotions = false;
  bool _initialized = false;

  List<RemoteMessage> get messages => _messages;
  bool get isSubscribedToOffers => _isSubscribedToOffers;
  bool get isSubscribedToNewProducts => _isSubscribedToNewProducts;
  bool get isSubscribedToPromotions => _isSubscribedToPromotions;
  int get unreadCount => _messages.length;

  /// Llama este método una sola vez, idealmente desde el widget raíz
  /// o desde HomeScreen.initState(). No se llama en el constructor
  /// para no bloquear la construcción del árbol de widgets.
  Future<void> initialize() async {
    if (_initialized) return; // Evitar doble inicialización
    _initialized = true;

    try {
      debugPrint('NotificationProvider: inicializando...');
      await notificationRepository.initialize();

      // Escuchar mensajes en foreground
      notificationRepository.onMessage.listen((message) {
        _messages.insert(0, message);
        notifyListeners();
      });

      // Escuchar cuando se abre la app desde una notificación
      notificationRepository.onMessageOpenedApp.listen((message) {
        debugPrint(
          'NotificationProvider: app abierta desde notificación: '
          '${message.notification?.title}',
        );
        // TODO: Navegar a la ruta indicada en message.data['route']
      });

      debugPrint('NotificationProvider: inicialización OK');
    } catch (e, st) {
      debugPrint('NotificationProvider ERROR (no crítico): $e');
      debugPrintStack(stackTrace: st);
      _initialized = false; // Permitir reintento si fue un error temporal
      // No rethrow — las notificaciones no deben impedir que la app arranque
    }
  }

  Future<void> toggleOffers(bool value) async {
    _isSubscribedToOffers = value;
    try {
      if (value) {
        await notificationRepository.subscribeToTopic(
          FirebaseConstants.offersTopicKey,
        );
      } else {
        await notificationRepository.unsubscribeFromTopic(
          FirebaseConstants.offersTopicKey,
        );
      }
    } catch (e) {
      debugPrint('NotificationProvider toggleOffers ERROR: $e');
    }
    notifyListeners();
  }

  Future<void> toggleNewProducts(bool value) async {
    _isSubscribedToNewProducts = value;
    try {
      if (value) {
        await notificationRepository.subscribeToTopic(
          FirebaseConstants.newProductsTopicKey,
        );
      } else {
        await notificationRepository.unsubscribeFromTopic(
          FirebaseConstants.newProductsTopicKey,
        );
      }
    } catch (e) {
      debugPrint('NotificationProvider toggleNewProducts ERROR: $e');
    }
    notifyListeners();
  }

  Future<void> togglePromotions(bool value) async {
    _isSubscribedToPromotions = value;
    try {
      if (value) {
        await notificationRepository.subscribeToTopic(
          FirebaseConstants.promotionsTopicKey,
        );
      } else {
        await notificationRepository.unsubscribeFromTopic(
          FirebaseConstants.promotionsTopicKey,
        );
      }
    } catch (e) {
      debugPrint('NotificationProvider togglePromotions ERROR: $e');
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}