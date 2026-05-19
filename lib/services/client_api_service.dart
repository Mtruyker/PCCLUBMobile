import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import '../models/booking.dart';
import '../models/cart_item.dart';
import '../models/catalog_item.dart';
import '../models/client_profile.dart';
import '../models/news_item.dart';
import '../models/order.dart';
import '../models/session.dart';
import 'local_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ApiException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class AuthSession {
  final String? accessToken;
  final String? refreshToken;
  final ClientProfile? profile;
  final int? clientId;

  const AuthSession({
    this.accessToken,
    this.refreshToken,
    this.profile,
    this.clientId,
  });

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
}

class ClientApiService {
  static final ClientApiService _instance = ClientApiService._internal();
  factory ClientApiService() => _instance;
  ClientApiService._internal();

  String? _authToken;

  Future<void> restoreSession() async {
    final storedToken = await LocalStorageService.getAuthToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      _authToken = storedToken;
    }
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> setAndPersistAuthToken(String token) async {
    _authToken = token;
    await LocalStorageService.saveAuthToken(token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await LocalStorageService.clearSession();
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<T> _request<T>(
    Future<http.Response> Function() request,
    T Function(dynamic body) parser, {
    Duration? timeout,
    bool allowInvalidJsonBody = false,
    String? debugLabel,
  }) async {
    try {
      final response = await request().timeout(timeout ?? EnvConfig.apiTimeout);
      _logResponse(debugLabel, response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildApiException(response);
      }

      dynamic decoded;
      try {
        decoded = _decodeBody(response);
      } on ApiException catch (e) {
        if (!allowInvalidJsonBody || e.message != 'Некорректный JSON') {
          rethrow;
        }
        decoded = null;
      }

      return parser(_unwrapData(decoded));
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Сетевая ошибка: ${e.toString()}');
    }
  }

  Future<T> _requestWithFallback<T>(
    List<Future<http.Response> Function()> requests,
    T Function(dynamic body) parser, {
    Duration? timeout,
    bool allowInvalidJsonBody = false,
    String? debugLabel,
  }) async {
    ApiException? lastError;

    for (var index = 0; index < requests.length; index++) {
      try {
        return await _request(
          requests[index],
          parser,
          timeout: timeout,
          allowInvalidJsonBody: allowInvalidJsonBody,
          debugLabel: debugLabel == null ? null : '$debugLabel [attempt ${index + 1}]',
        );
      } on ApiException catch (e) {
        lastError = e;
        final shouldTryNext = e.statusCode == 404 && index < requests.length - 1;
        if (!shouldTryNext) {
          rethrow;
        }
      }
    }

    throw lastError ?? ApiException('Не удалось выполнить запрос');
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return json.decode(response.body);
    } on FormatException {
      throw ApiException('Некорректный JSON', statusCode: response.statusCode);
    }
  }

  dynamic _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) {
        return data['data'];
      }
      if (data.containsKey('result')) {
        return data['result'];
      }
    }
    return data;
  }

  ApiException _buildApiException(http.Response response) {
    dynamic decoded;
    try {
      decoded = _decodeBody(response);
    } on ApiException {
      decoded = null;
    }

    if (decoded is Map<String, dynamic>) {
      final message = (decoded['message'] ??
              decoded['error'] ??
              decoded['details'] ??
              'Ошибка сервера (${response.statusCode})')
          .toString();
      final code = decoded['code']?.toString();
      return ApiException(message, code: code, statusCode: response.statusCode);
    }

    return ApiException(
      response.body.isNotEmpty ? response.body : 'Ошибка сервера (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _asMap(dynamic data, {String errorMessage = 'Неверный формат ответа сервера'}) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(errorMessage);
  }

  List<dynamic> _asList(dynamic data, {String errorMessage = 'Неверный формат ответа сервера'}) {
    if (data is List) {
      return data;
    }
    throw ApiException(errorMessage);
  }

  int? _extractClientId(Map<String, dynamic> data) {
    final dynamic rawId = data['clientId'] ?? data['id'] ?? data['userId'];
    if (rawId is int) {
      return rawId;
    }
    if (rawId is String) {
      return int.tryParse(rawId);
    }
    return null;
  }

  int _requireStoredClientId() {
    final clientId = LocalStorageService.getClientId();
    if (clientId == null) {
      throw ApiException('Пользователь не авторизован');
    }
    return clientId;
  }

  String? _extractAccessToken(Map<String, dynamic> data) {
    final dynamic rawToken = data['accessToken'] ?? data['token'] ?? data['jwt'];
    if (rawToken is String && rawToken.isNotEmpty) {
      return rawToken;
    }
    return null;
  }

  String? _extractRefreshToken(Map<String, dynamic> data) {
    final dynamic rawToken = data['refreshToken'];
    if (rawToken is String && rawToken.isNotEmpty) {
      return rawToken;
    }
    return null;
  }

  ClientProfile? _extractProfile(Map<String, dynamic> data) {
    final dynamic nested = data['client'] ?? data['user'] ?? data['profile'];
    if (nested is Map) {
      return ClientProfile.fromJson(Map<String, dynamic>.from(nested));
    }

    if (data.containsKey('name') || data.containsKey('phone') || data.containsKey('email')) {
      return ClientProfile.fromJson(data);
    }

    return null;
  }

  void _logResponse(String? debugLabel, http.Response response) {
    if (!kDebugMode || debugLabel == null) {
      return;
    }

    debugPrint('[$debugLabel] status: ${response.statusCode}');
    debugPrint('[$debugLabel] headers: ${response.headers}');
    debugPrint('[$debugLabel] body: ${response.body}');
  }

  Future<AuthSession> register(
    String name,
    String phone,
    String password,
    String email,
  ) async {
    final payload = json.encode({
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    });

    final result = await _requestWithFallback(
      [
        () => http.post(
              Uri.parse('${EnvConfig.apiBaseUrl}/auth/register'),
              headers: _headers,
              body: payload,
            ),
        () => http.post(
              Uri.parse('${EnvConfig.apiBaseUrl}/clients'),
              headers: _headers,
              body: payload,
            ),
      ],
      (data) => _parseRegisterSession(data),
      allowInvalidJsonBody: true,
      debugLabel: 'register',
    );

    await _persistAuthSession(result);
    return result;
  }

  Future<AuthSession> login(String phone, String password) async {
    final payload = json.encode({'phone': phone, 'password': password});
    final result = await _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/auth/login'),
        headers: _headers,
        body: payload,
      ),
      (data) => _parseAuthSession(data),
      debugLabel: 'login',
    );

    await _persistAuthSession(result);
    return result;
  }

  AuthSession _parseAuthSession(dynamic data) {
    final body = _asMap(data);
    return AuthSession(
      accessToken: _extractAccessToken(body),
      refreshToken: _extractRefreshToken(body),
      profile: _extractProfile(body),
      clientId: _extractClientId(body) ?? _extractProfile(body)?.id,
    );
  }

  AuthSession _parseRegisterSession(dynamic data) {
    if (data == null) {
      return const AuthSession();
    }

    if (data is String) {
      return const AuthSession();
    }

    return _parseAuthSession(data);
  }

  Future<void> _persistAuthSession(AuthSession session) async {
    if (session.accessToken != null) {
      await setAndPersistAuthToken(session.accessToken!);
    }
    if (session.clientId != null) {
      await LocalStorageService.saveClientId(session.clientId!);
    }
    if (session.profile != null) {
      await LocalStorageService.saveClientProfile(session.profile!);
    }
  }

  Future<ClientProfile> getClientProfile() async {
    final clientId = _requireStoredClientId();

    try {
      final profile = await _request(
        () => http.get(
          Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId'),
          headers: _headers,
        ),
        (data) => ClientProfile.fromJson(_asMap(data)),
      );
      await LocalStorageService.saveClientProfile(profile);
      await LocalStorageService.saveClientId(profile.id);
      return profile;
    } catch (e) {
      final storedId = LocalStorageService.getClientId();
      if (storedId != null) {
        final backup = await LocalStorageService.getClientProfileFromBackup(storedId);
        if (backup != null) {
          return backup;
        }
      }
      rethrow;
    }
  }

  Future<List<CatalogItem>> getCatalogItems() async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/items'),
        headers: _headers,
      ),
      (data) => _asList(data).map((item) => CatalogItem.fromJson(_asMap(item))).toList(),
    );
  }

  Future<List<NewsItem>> getNews() async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/news'),
        headers: _headers,
      ),
      (data) => _asList(data).map((item) => NewsItem.fromJson(_asMap(item))).toList(),
    );
  }

  Future<bool> placeOrder(List<CartItem> items) async {
    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/orders'),
        headers: _headers,
        body: json.encode({
          'items': items
              .map((item) => {'productId': item.product.id, 'quantity': item.quantity})
              .toList(),
        }),
      ),
      (_) => true,
    );
  }

  Future<List<Session>> getSessionHistory() async {
    final clientId = _requireStoredClientId();

    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/sessions'),
        headers: _headers,
      ),
      (data) => _asList(data).map((item) => Session.fromJson(_asMap(item))).toList(),
    );
  }

  Future<List<Booking>> getActiveBookings() async {
    final clientId = _requireStoredClientId();

    try {
      return await _request(
        () => http.get(
          Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/bookings'),
          headers: _headers,
        ),
        (data) => _asList(data).map((item) => Booking.fromJson(_asMap(item))).toList(),
      );
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getAvailablePCs() async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/pcs/available'),
        headers: _headers,
      ),
      (data) => _asList(data)
          .map((pc) {
            if (pc is String) {
              return pc;
            }

            final map = _asMap(pc);
            return (map['name'] ?? map['number'] ?? map['label'] ?? '').toString();
          })
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }

  Future<bool> createBooking(String pcName, DateTime startTime, int duration) async {
    final clientId = _requireStoredClientId();
    final normalizedStartTime = startTime.toUtc().toIso8601String();

    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/bookings'),
        headers: _headers,
        body: json.encode({
          'clientId': clientId,
          'pcName': pcName,
          'startTime': normalizedStartTime,
          'duration': duration,
        }),
      ),
      (_) => true,
      timeout: EnvConfig.apiTimeoutLong,
    );
  }

  Future<void> updateClient(ClientProfile profile) async {
    await _request(
      () => http.put(
        Uri.parse('${EnvConfig.apiBaseUrl}/clients/${profile.id}'),
        headers: _headers,
        body: json.encode(profile.toJson()),
      ),
      (_) {},
    );
  }

  Future<List<Order>> getClientOrders() async {
    final clientId = _requireStoredClientId();

    try {
      return await _request(
        () => http.get(
          Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/orders'),
          headers: _headers,
        ),
        (data) => _asList(data).map((item) => Order.fromJson(_asMap(item))).toList(),
      );
    } catch (_) {
      return [];
    }
  }
}
