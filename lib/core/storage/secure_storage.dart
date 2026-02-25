import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageProvider = Provider((_) => SecureStorage());

class SecureStorage {
  static const _tokenKey = 'mina_jwt_token';
  static const _userKey  = 'mina_user_json';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveToken(String token) async =>
      (await _prefs).setString(_tokenKey, token);

  Future<String?> getToken() async =>
      (await _prefs).getString(_tokenKey);

  Future<void> deleteToken() async =>
      (await _prefs).remove(_tokenKey);

  Future<bool> hasToken() async {
    final token = (await _prefs).getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUser(String json) async =>
      (await _prefs).setString(_userKey, json);

  Future<String?> getUser() async =>
      (await _prefs).getString(_userKey);

  Future<void> deleteUser() async =>
      (await _prefs).remove(_userKey);

  Future<void> clear() async =>
      (await _prefs).clear();
}