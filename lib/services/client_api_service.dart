import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env_config.dart';
import '../models/client_profile.dart';
import '../models/catalog_item.dart';
import '../models/news_item.dart';
import '../models/session.dart';
import '../models/booking.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'local_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ClientApiService {
  static final ClientApiService _instance = ClientApiService._internal();
  factory ClientApiService() => _instance;
  ClientApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<T> _request<T>(
    Future<http.Response> Function() request,
    T Function(dynamic) parser,
  ) async {
    try {
      final response = await request().timeout(EnvConfig.apiTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return parser(data);
      } else {
        throw ApiException(_getErrorMessage(response), statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Сетевая ошибка: ${e.toString()}');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map) {
        return (data['error'] ?? data['message'] ?? response.body).toString();
      }
    } catch (_) {}
    return 'Ошибка сервера (${response.statusCode})';
  }

  Future<ClientProfile> getClientProfile(int clientId) async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/clients'),
        headers: _headers,
      ),
      (data) {
        final list = data as List;
        final clientJson = list.firstWhere(
          (c) => c['id'] == clientId,
          orElse: () => throw ApiException('Клиент не найден'),
        );
        return ClientProfile.fromJson(clientJson);
      },
    ).catchError((_) async {
      final backup = await LocalStorageService.getClientProfileFromBackup(clientId);
      if (backup != null) return backup;
      throw ApiException('Нет сохранённых данных');
    });
  }

  Future<int> register(String name, String phone, String password, String email) async {
    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/clients'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'balance': 0.0,
        }),
      ),
      (data) => data['id'] as int,
    );
  }

  Future<int> login(String phone, String password) async {
    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/auth/login'),
        headers: _headers,
        body: json.encode({'phone': phone, 'password': password}),
      ),
      (data) {
        if (data is Map) {
          if (data['token'] != null) {
            setAuthToken(data['token'].toString());
          }
          return data['clientId'] as int;
        }
        throw ApiException('Неверный формат ответа сервера');
      },
    );
  }

  Future<List<CatalogItem>> getCatalogItems() async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/items'),
        headers: _headers,
      ),
      (data) => (data as List).map((item) => CatalogItem.fromJson(item)).toList(),
    );
  }

  Future<List<NewsItem>> getNews() async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/news'),
        headers: _headers,
      ),
      (data) => (data as List).map((item) => NewsItem.fromJson(item)).toList(),
    );
  }

  Future<bool> placeOrder(int clientId, List<CartItem> items) async {
    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/orders'),
        headers: _headers,
        body: json.encode({
          'clientId': clientId,
          'items': items.map((i) => {'productId': i.product.id, 'quantity': i.quantity}).toList(),
          'date': DateTime.now().toIso8601String(),
        }),
      ),
      (_) => true,
    );
  }

  Future<List<Session>> getSessionHistory(int clientId) async {
    return _request(
      () => http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/sessions'),
        headers: _headers,
      ),
      (data) => (data as List).map((s) => Session.fromJson(s)).toList(),
    );
  }

  Future<List<Booking>> getActiveBookings(int clientId) async {
    try {
      return await _request(
        () => http.get(
          Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/bookings'),
          headers: _headers,
        ),
        (data) => (data as List).map((b) => Booking.fromJson(b)).toList(),
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
      (data) => (data as List)
          .map((pc) => pc is String ? pc : (pc as Map)['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }

  Future<bool> createBooking(int clientId, String pcName, DateTime startTime, int duration) async {
    return _request(
      () => http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/bookings'),
        headers: _headers,
        body: json.encode({
          'clientId': clientId,
          'pcName': pcName,
          'startTime': startTime.toIso8601String(),
          'duration': duration,
        }),
      ).timeout(EnvConfig.apiTimeoutLong),
      (_) => true,
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

  Future<List<Order>> getClientOrders(int clientId) async {
    try {
      return await _request(
        () => http.get(
          Uri.parse('${EnvConfig.apiBaseUrl}/clients/$clientId/orders'),
          headers: _headers,
        ),
        (data) => (data as List).map((o) => Order.fromJson(o)).toList(),
      );
    } catch (_) {
      // Возвращаем пустой список если API недоступен
      return [];
    }
  }
}
