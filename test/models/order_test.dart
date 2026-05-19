import 'package:flutter_test/flutter_test.dart';
import 'package:pc_club_mobile/models/order.dart';

void main() {
  group('Order Model Tests', () {
    test('Order creation with valid data', () {
      final order = Order(
        id: 1,
        date: DateTime(2026, 5, 19),
        items: [
          OrderItem(productName: 'Test Product', quantity: 2, price: 100.0),
        ],
        totalAmount: 200.0,
        status: 'delivered',
      );

      expect(order.id, 1);
      expect(order.date, DateTime(2026, 5, 19));
      expect(order.items.length, 1);
      expect(order.totalAmount, 200.0);
      expect(order.status, 'delivered');
    });

    test('OrderItem creation with valid data', () {
      final orderItem = OrderItem(
        productName: 'Coca-Cola',
        quantity: 3,
        price: 50.0,
      );

      expect(orderItem.productName, 'Coca-Cola');
      expect(orderItem.quantity, 3);
      expect(orderItem.price, 50.0);
    });

    test('Order JSON serialization', () {
      final order = Order(
        id: 1,
        date: DateTime(2026, 5, 19),
        items: [
          OrderItem(productName: 'Test Product', quantity: 2, price: 100.0),
        ],
        totalAmount: 200.0,
        status: 'delivered',
      );

      final json = order.toJson();
      expect(json['id'], 1);
      expect(json['totalAmount'], 200.0);
      expect(json['status'], 'delivered');
      expect(json['items'], isA<List>());
    });

    test('Order JSON deserialization', () {
      final json = {
        'id': 1,
        'date': '2026-05-19T00:00:00.000',
        'items': [
          {'productName': 'Test Product', 'quantity': 2, 'price': 100.0}
        ],
        'totalAmount': 200.0,
        'status': 'delivered',
      };

      final order = Order.fromJson(json);
      expect(order.id, 1);
      expect(order.totalAmount, 200.0);
      expect(order.status, 'delivered');
      expect(order.items.length, 1);
      expect(order.items.first.productName, 'Test Product');
    });
  });
}