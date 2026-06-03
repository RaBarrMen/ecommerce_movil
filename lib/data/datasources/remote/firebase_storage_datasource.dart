import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firebase_constants.dart';

abstract class FirebaseStorageDatasource {
  Future<String> uploadProfileImage(String userId, File file);
  Future<String> uploadProductImage(String productId, File file);
  Future<void> deleteFile(String url);
}

class FirebaseStorageDatasourceImpl implements FirebaseStorageDatasource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadProfileImage(String userId, File file) async {
    final ref = _storage
        .ref()
        .child(FirebaseConstants.profileImagesPath)
        .child('$userId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Future<String> uploadProductImage(String productId, File file) async {
    final ref = _storage
        .ref()
        .child(FirebaseConstants.productImagesPath)
        .child('${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}