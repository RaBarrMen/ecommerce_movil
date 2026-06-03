import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? iconUrl;
  final int order;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.order = 0,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: d['name'] ?? '',
      iconUrl: d['iconUrl'],
      order: d['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'iconUrl': iconUrl,
        'order': order,
      };
}