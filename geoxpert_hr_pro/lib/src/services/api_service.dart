import 'dart:convert';
import 'dart:developer';
import 'package:geoxpert_hr_pro/src/constants/api_url.dart';
import 'package:geoxpert_hr_pro/src/services/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../model/User.dart';

class ApiService {
  final TokenStorage _tokenStorage = TokenStorage();

  Uri _getUri(String endpoint) {
    return Uri.parse('${ApiUrl.baseUrl}$endpoint');
  }

  Future<String?> _accessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  Future<String> _refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception("Refresh token is missing");
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/api/auth/refresh'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
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
        );

        await _tokenStorage.saveTokens(newAccessToken, newRefreshToken, user);
        return newAccessToken;
      } else {
        log("Failed to refresh token: ${response.body}");
        throw Exception("Token refresh failed");
      }
    } catch (e) {
      log("Error refreshing token: $e");
      throw Exception("Token refresh failed");
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await _accessToken();
    if (token == null) throw Exception("Access token is missing or expired");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunc,
      Uri uri, {
        dynamic body,
        bool isRetry = false,
      }) async {
    try {
      _logRequest(uri, body);
      final response = await requestFunc();
      _logResponse(uri, response);

      if (_isUnauthorized(response.statusCode)) {
        if (isRetry) {
          throw Exception("Unauthorized even after token refresh");
        }

        await _refreshToken();
        return _sendRequest(requestFunc, uri, body: body, isRetry: true);
      }
      return response;
    } catch (e) {
      log("Error during API call to $uri: $e");
      rethrow;
    }
  }

  void _logRequest(Uri uri, dynamic body) {
    log("Request URL: $uri");
    if (body != null) log("Request Body: ${jsonEncode(body)}");
  }

  void _logResponse(Uri uri, http.Response response) {
    log("Response for URL: $uri");
    log("Status Code: ${response.statusCode}");
    log("Response Body: ${response.body}");
  }

  bool _isUnauthorized(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  Future<http.Response> get(String endpoint) async {
    final uri = _getUri(endpoint);
    return _sendRequest(() async => http.get(uri, headers: await _headers()), uri);
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    final uri = _getUri(endpoint);
    return _sendRequest(
          () async => http.post(uri, headers: await _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    final uri = _getUri(endpoint);
    return _sendRequest(
          () async => http.put(uri, headers: await _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> patch(String endpoint, dynamic body) async {
    final uri = _getUri(endpoint);
    return _sendRequest(
          () async => http.patch(uri, headers: await _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> delete(String endpoint, {dynamic body}) async {
    final uri = _getUri(endpoint);
    return _sendRequest(
          () async => http.delete(uri, headers: await _headers(), body: jsonEncode(body)),
      uri,
      body: body,
    );
  }

  Future<http.Response> updateProfileImage(String imagePath, String endpoint) async {
    final uri = _getUri(endpoint);
    final request = http.MultipartRequest('PATCH', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath))
      ..headers.addAll(await _headers());

    _logRequest(uri, {"imagePath": imagePath});

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(uri, response);

    if (_isUnauthorized(response.statusCode)) {
      await _refreshToken();
      return updateProfileImage(imagePath, endpoint);
    }

    return response;
  }
}