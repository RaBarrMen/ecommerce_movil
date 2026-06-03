import 'dart:io';
import '../datasources/remote/firebase_storage_datasource.dart';

abstract class StorageRepository {
  Future<String> uploadProfileImage(String userId, File file);
}

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageDatasource storageDatasource;
  StorageRepositoryImpl({required this.storageDatasource});

  @override
  Future<String> uploadProfileImage(String userId, File file) =>
      storageDatasource.uploadProfileImage(userId, file);
}