import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import '../models/booking.dart';
import '../models/cart_item.dart';
import '../models/catalog_item.dart';
import '../models/client_profile.dart';
import '../models/news_item.dart';
import '../models/order.dart';
import '../models/session.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'booking_service.dart';
import 'catalog_service.dart';
import 'news_service.dart';
import 'order_service.dart';
import 'profile_service.dart';
import 'local_storage_service.dart';

export 'api_client.dart';
export 'auth_service.dart';
export 'booking_service.dart';
export 'catalog_service.dart';
export 'news_service.dart';
export 'order_service.dart';

class ClientApiService {
  static final ClientApiService _instance = ClientApiService._internal();
  factory ClientApiService() => _instance;
  ClientApiService._internal()
      : _authService = AuthService(_apiClient),
        _bookingService = BookingService(_apiClient),
        _catalogService = CatalogService(_apiClient),
        _newsService = NewsService(_apiClient),
        _orderService = OrderService(_apiClient),
        _profileService = ProfileService(_apiClient);

  static final ApiClient _apiClient = ApiClient();

  final AuthService _authService;
  final BookingService _bookingService;
  final CatalogService _catalogService;
  final NewsService _newsService;
  final OrderService _orderService;
  final ProfileService _profileService;

  Future<void> restoreSession() => _authService.restoreSession();

  void setAuthToken(String token) {
    _authService.setAuthToken(token);
  }

  Future<void> setAndPersistAuthToken(String token) {
    return _authService.setAndPersistAuthToken(token);
  }

  Future<void> clearAuthToken() {
    return _authService.clearAuthToken();
  }

  Map<String, String> get _headers => _apiClient.headers;

  Future<AuthSession> register(
    String name,
    String phone,
    String password,
    String email,
  ) {
    return _authService.register(name, phone, password, email);
  }

  Future<AuthSession> login(String phone, String password) {
    return _authService.login(phone, password);
  }

  Future<ClientProfile> getClientProfile() {
    return _profileService.getClientProfile();
  }

  Future<void> updateClient(ClientProfile profile) {
    return _profileService.updateClient(profile);
  }

  Map<String, dynamic> _asMap(
    dynamic data, {
    String errorMessage = 'Неверный формат ответа сервера',
  }) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(errorMessage);
  }

  List<dynamic> _asList(
    dynamic data, {
    String errorMessage = 'Неверный формат ответа сервера',
  }) {
    if (data is List) {
      return data;
    }
    throw ApiException(errorMessage);
  }

  int _requireStoredClientId() {
    final clientId = LocalStorageService.getClientId();
    if (clientId == null) {
      throw ApiException('Пользователь не авторизован');
    }
    return clientId;
  }

  Future<List<CatalogItem>> getCatalogItems() async {
    return _catalogService.getCatalogItems();
  }

  Future<List<NewsItem>> getNews() async {
    return _newsService.getNews();
  }

  Future<bool> placeOrder(List<CartItem> items) async {
    return _orderService.placeOrder(items);
  }

  Future<List<Session>> getSessionHistory() async {
    final clientId = _requireStoredClientId();

    return _apiClient.request(
      () => httpGet('/clients/$clientId/sessions'),
      (data) => _asList(data).map((item) => Session.fromJson(_asMap(item))).toList(),
    );
  }

  Future<List<Booking>> getActiveBookings() async {
    return _bookingService.getActiveBookings();
  }

  Future<List<String>> getAvailablePCs() async {
    return _bookingService.getAvailablePCs();
  }

  Future<bool> createBooking(String pcName, DateTime startTime, int duration) async {
    return _bookingService.createBooking(pcName, startTime, duration);
  }

  Future<List<Order>> getClientOrders() async {
    return _orderService.getClientOrders();
  }

  Future<http.Response> httpGet(String path) {
    return http.get(Uri.parse('${EnvConfig.apiBaseUrl}$path'), headers: _headers);
  }

  Future<http.Response> httpPost(String path, String payload) {
    return http.post(
      Uri.parse('${EnvConfig.apiBaseUrl}$path'),
      headers: _headers,
      body: payload,
    );
  }
}
