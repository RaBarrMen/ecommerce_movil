import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? route;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.route,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      imageUrl: d['imageUrl'],
      route: d['route'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        imageUrl: imageUrl,
        route: route,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'route': route,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}