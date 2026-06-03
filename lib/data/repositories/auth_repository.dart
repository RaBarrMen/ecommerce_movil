import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../datasources/local/local_cache_datasource.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  bool get isOnboardingDone;
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> completeOnboarding();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource authDatasource;
  final LocalCacheDatasource localCache;

  AuthRepositoryImpl({
    required this.authDatasource,
    required this.localCache,
  });

  @override
  User? get currentUser => authDatasource.currentUser;

  @override
  Stream<User?> get authStateChanges => authDatasource.authStateChanges;

  @override
  bool get isOnboardingDone => localCache.isOnboardingDone;

  @override
  Future<UserModel> signInWithGoogle() async {
    final credential = await authDatasource.signInWithGoogle();
    final firebaseUser = credential.user!;
    return UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<void> signOut() => authDatasource.signOut();

  @override
  Future<void> completeOnboarding() => localCache.setOnboardingDone();
}