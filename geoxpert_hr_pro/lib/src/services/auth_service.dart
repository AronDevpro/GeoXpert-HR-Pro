import 'dart:convert';
import 'package:geoxpert_hr_pro/src/services/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/api_url.dart';
import '../model/User.dart';
import '../providers/auth_notifier.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> login(
      String email, String password, AuthNotifier authNotifier) async {
    try {
      String? id = await OneSignal.User.getOnesignalId();
      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}auth'),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'email': email, 'password': password, 'appToken': id}),
      );
      print(response.body);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> userData = JwtDecoder.decode(data['accessToken']);

        User user = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            branch: userData['branch']['branchName'],
            branchId: userData['branch']['_id'],
            role: userData['role'],
            startTime: userData['contract']['officeShift']['startTime'],
            endTime: userData['contract']['officeShift']['endTime'],
            longitude: userData['branch']['longitude'],
            latitude: userData['branch']['latitude'],
            radius: userData['branch']['radius'],
            photo: userData['photo']);
        await _tokenStorage.saveTokens(
            data['accessToken'], data['refreshToken'], user);
        authNotifier.setLoggedIn(true);
        return true;
      }
      return false;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  Future<void> logout(AuthNotifier authNotifier) async {
    await _tokenStorage.clearTokens();
    OneSignal.logout();
    authNotifier.setLoggedIn(false);
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> userData = JwtDecoder.decode(data['accessToken']);

        User user = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            branch: userData['branch']['branchName'],
            branchId: userData['branch']['_id'],
            role: userData['role'],
            startTime: userData['contract']['officeShift']['startTime'],
            endTime: userData['contract']['officeShift']['endTime'],
            longitude: userData['branch']['longitude'],
            latitude: userData['branch']['latitude'],
            radius: userData['branch']['radius'],
            photo: userData['photo']);
        await _tokenStorage.saveTokens(
            data['accessToken'], data['refreshToken'], user);
        return data['accessToken'];
      }
      return null;
    } catch (e) {
      print("Error refreshing access token: $e");
      return null;
    }
  }

  Future<bool> checkAuthStatus() async {
    bool isExpired = await isTokenExpired();
    if (isExpired) {
      String? newAccessToken = await refreshAccessToken();
      return newAccessToken != null;
    }
    return true;
  }

  Future<bool> isTokenExpired() async {
    String? accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      return JwtDecoder.isExpired(accessToken);
    }
    return true;
  }
}
