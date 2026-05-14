import 'cart_item.dart';
import 'catalog_item.dart';

class Order {
  final int id;
  final DateTime date;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'delivered', 'cancelled'

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'] ?? 0,
      date: DateTime.parse(json['date']),
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
