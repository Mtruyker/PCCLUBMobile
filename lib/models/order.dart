class Order {
  final int id;
  final DateTime date;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final rawDate = json['date'] ?? json['createdAt'] ?? json['orderedAt'];
    final rawTotal = json['totalAmount'] ?? json['total'] ?? json['amount'] ?? 0.0;
    final rawId = json['id'] ?? 0;

    return Order(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      date: DateTime.parse(rawDate.toString()),
      items: rawItems
          .whereType<Object>()
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      totalAmount: (rawTotal as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'new').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
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
    final rawProduct = json['product'];
    final rawName = json['productName'] ??
        json['name'] ??
        (rawProduct is Map ? rawProduct['name'] : null) ??
        '';
    final rawQuantity = json['quantity'] ?? 1;
    final rawPrice = json['price'] ??
        json['unitPrice'] ??
        (rawProduct is Map ? rawProduct['price'] : null) ??
        0.0;

    return OrderItem(
      productName: rawName.toString(),
      quantity: rawQuantity is int ? rawQuantity : int.tryParse(rawQuantity.toString()) ?? 1,
      price: (rawPrice as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
