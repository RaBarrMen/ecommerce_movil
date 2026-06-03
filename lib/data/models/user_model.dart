import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String? address;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'phone': phone,
        'address': address,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? phone,
    String? address,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        createdAt: createdAt,
      );
}