import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/client_profile.dart';
import '../models/catalog_item.dart';
import '../models/news_item.dart';
import '../models/session.dart';
import '../models/booking.dart';
import '../models/cart_item.dart';
import 'local_storage_service.dart';

class ClientApiService {
  static const String baseUrl = 'https://serverpcclub-production.up.railway.app/api';

  // Получение профиля клиента
  Future<ClientProfile> getClientProfile(int clientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clients'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        var clientJson = data.firstWhere(
          (c) => c['id'] == clientId,
          orElse: () => throw Exception('Client not found'),
        );
        return ClientProfile.fromJson(clientJson);
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      return await LocalStorageService.getClientProfileFromBackup(clientId);
    }
  }

  // Регистрация нового клиента
  Future<int> register(String name, String phone, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phone': phone,
        'password': password,
        'email': email,
        'balance': 0.0,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      throw Exception('Ошибка при регистрации: ${response.body}');
    }
  }

  // Вход в систему (упрощенно)
  Future<int> login(String phone, String password) async {
    // В реальности здесь был бы запрос к /api/login, который возвращает JWT и ID
    // Пока ищем клиента по номеру телефона в списке
    final response = await http.get(Uri.parse('$baseUrl/clients'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      var client = data.firstWhere(
        (c) => c['phone'] == phone,
        orElse: () => throw Exception('Пользователь не найден'),
      );
      return client['id'];
    } else {
      throw Exception('Ошибка авторизации');
    }
  }

  // Каталог товаров и услуг
  Future<List<CatalogItem>> getCatalogItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => CatalogItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load catalog');
    }
  }

  // Новости клуба
  Future<List<NewsItem>> getNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => NewsItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  // Оформление заказа (товары из корзины)
  Future<bool> placeOrder(int clientId, List<CartItem> items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'clientId': clientId,
        'items': items.map((i) => {
          'productId': i.product.id,
          'quantity': i.quantity,
        }).toList(),
        'date': DateTime.now().toIso8601String(),
      }),
    ).timeout(const Duration(seconds: 10));

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // История сессий клиента
  Future<List<Session>> getSessionHistory(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/clients/$clientId/sessions'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((s) => Session.fromJson(s)).toList();
    } else {
      throw Exception('Failed to load session history');
    }
  }

  // Активные бронирования клиента
  Future<List<Booking>> getActiveBookings(int clientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clients/$clientId/bookings'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((b) => Booking.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Список доступных ПК для бронирования
  Future<List<String>> getAvailablePCs() async {
    final response = await http.get(Uri.parse('$baseUrl/pcs/available'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load available PCs');
    }
  }

  // Создание нового бронирования
  Future<bool> createBooking(int clientId, String pcName, DateTime startTime, int duration) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'clientId': clientId,
        'pcName': pcName,
        'startTime': startTime.toIso8601String(),
        'duration': duration,
      }),
    ).timeout(const Duration(seconds: 15));

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // Обновление профиля клиента
  Future<void> updateClient(ClientProfile profile) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/${profile.id}'),
      body: json.encode(profile.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update client');
    }
  }
}
