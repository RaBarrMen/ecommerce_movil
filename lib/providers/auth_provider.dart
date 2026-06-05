import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    debugPrint('AuthProvider: constructor, iniciando listener de auth...');
    _listenToAuthChanges();
  }

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get onboardingDone => authRepository.isOnboardingDone;

  void _listenToAuthChanges() {
    try {
      authRepository.authStateChanges.listen(
        (User? firebaseUser) {
          if (firebaseUser != null) {
            debugPrint('AuthProvider: usuario autenticado — ${firebaseUser.uid}');
            _user = UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              photoUrl: firebaseUser.photoURL,
            );
            _status = AuthStatus.authenticated;
          } else {
            debugPrint('AuthProvider: sin usuario (unauthenticated)');
            _user = null;
            _status = AuthStatus.unauthenticated;
          }
          notifyListeners();
        },
        onError: (e, st) {
          // Captura errores del Stream (ej. Firebase no inicializado)
          debugPrint('AuthProvider Stream ERROR: $e');
          debugPrintStack(stackTrace: st);
          _status = AuthStatus.error;
          _errorMessage = e.toString();
          notifyListeners();
        },
      );
    } catch (e, st) {
      // Captura si FirebaseAuth.instance lanza al crear el stream
      debugPrint('AuthProvider _listenToAuthChanges ERROR: $e');
      debugPrintStack(stackTrace: st);
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      debugPrint('AuthProvider: iniciando signInWithGoogle...');
      _user = await authRepository.signInWithGoogle();
      _status = AuthStatus.authenticated;
      debugPrint('AuthProvider: signInWithGoogle OK — ${_user?.uid}');
    } catch (e, st) {
      debugPrint('AuthProvider signInWithGoogle ERROR: $e');
      debugPrintStack(stackTrace: st);
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
    } catch (e) {
      debugPrint('AuthProvider signOut ERROR: $e');
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await authRepository.completeOnboarding();
    notifyListeners();
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }
}