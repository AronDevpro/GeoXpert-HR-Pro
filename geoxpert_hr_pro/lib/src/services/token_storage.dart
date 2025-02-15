import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geoxpert_hr_pro/src/model/User.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken, User user) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(key: 'user', value: jsonEncode(user.toMap()));
  }

  Future<String?> getAccessToken() async => await _storage.read(key: 'accessToken');
  Future<String?> getRefreshToken() async => await _storage.read(key: 'refreshToken');
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromMap(userMap);
    }
    return null;
  }
  Future<void> clearTokens() async {await _storage.deleteAll();}
}