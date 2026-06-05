import 'dart:io';
import '../datasources/remote/firebase_storage_datasource.dart';

abstract class StorageRepository {
  Future<String> uploadProfileImage(String userId, File file);
  Future<String> uploadProductImage(String productId, File file);
  Future<void> deleteFile(String url);
}

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageDatasource storageDatasource;
  StorageRepositoryImpl({required this.storageDatasource});

  @override
  Future<String> uploadProfileImage(String userId, File file) =>
      storageDatasource.uploadProfileImage(userId, file);

  @override
  Future<String> uploadProductImage(String productId, File file) =>
      storageDatasource.uploadProductImage(productId, file);

  @override
  Future<void> deleteFile(String url) => storageDatasource.deleteFile(url);
}
