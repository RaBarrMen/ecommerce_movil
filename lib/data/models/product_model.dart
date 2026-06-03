import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> imageUrls;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrls,
    required this.categoryId,
    required this.categoryName,
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isActive = true,
    this.createdAt,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  bool get isInStock => stock > 0;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      discountPrice: d['discountPrice'] != null
          ? (d['discountPrice']).toDouble()
          : null,
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      categoryId: d['categoryId'] ?? '',
      categoryName: d['categoryName'] ?? '',
      rating: (d['rating'] ?? 0).toDouble(),
      reviewCount: d['reviewCount'] ?? 0,
      stock: d['stock'] ?? 0,
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'discountPrice': discountPrice,
        'imageUrls': imageUrls,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'isActive': isActive,
        'createdAt':
            createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };
}