import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/firebase_constants.dart';

abstract class LocalCacheDatasource {
  bool get isOnboardingDone;
  Future<void> setOnboardingDone();
  Future<void> saveString(String key, String value);
  String? getString(String key);
  Future<void> saveJson(String key, Map<String, dynamic> json);
  Map<String, dynamic>? getJson(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class LocalCacheDatasourceImpl implements LocalCacheDatasource {
  final SharedPreferences prefs;
  LocalCacheDatasourceImpl({required this.prefs});

  @override
  bool get isOnboardingDone =>
      prefs.getBool(FirebaseConstants.onboardingDoneKey) ?? false;

  @override
  Future<void> setOnboardingDone() =>
      prefs.setBool(FirebaseConstants.onboardingDoneKey, true);

  @override
  Future<void> saveString(String key, String value) =>
      prefs.setString(key, value);

  @override
  String? getString(String key) => prefs.getString(key);

  @override
  Future<void> saveJson(String key, Map<String, dynamic> json) =>
      prefs.setString(key, jsonEncode(json));

  @override
  Map<String, dynamic>? getJson(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> remove(String key) => prefs.remove(key);

  @override
  Future<void> clear() => prefs.clear();
}