import 'package:flutter/material.dart';
import '../services/client_api_service.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int clientId;

  const OrderHistoryScreen({super.key, required this.clientId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ClientApiService _apiService = ClientApiService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Имитация получения заказов, пока эндпоинт на сервере может быть не готов
      await Future.delayed(const Duration(milliseconds: 500));
      // В реальности: _orders = await _apiService.getClientOrders(widget.clientId);
      
      // Заглушка для теста
      _orders = [
        Order(
          id: 501,
          date: DateTime.now().subtract(const Duration(days: 1)),
          items: [
            OrderItem(productName: 'Coca-Cola 0.5', quantity: 2, price: 90),
            OrderItem(productName: 'Chips Lays', quantity: 1, price: 120),
          ],
          totalAmount: 300,
          status: 'delivered',
        ),
        Order(
          id: 502,
          date: DateTime.now().subtract(const Duration(days: 3)),
          items: [
            OrderItem(productName: 'Energy Drink Red Bull', quantity: 1, price: 180),
          ],
          totalAmount: 180,
          status: 'delivered',
        ),
      ];
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Вы еще ничего не заказывали'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.fastfood, color: Colors.white, size: 20),
        ),
        title: Text('Заказ #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(order.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${order.totalAmount.toStringAsFixed(0)} ₽', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Text(order.status == 'delivered' ? 'Доставлено' : 'В обработке', 
              style: TextStyle(fontSize: 10, color: order.status == 'delivered' ? Colors.green : Colors.orange)),
          ],
        ),
        children: [
          const Divider(),
          ...order.items.map((item) => ListTile(
            dense: true,
            title: Text(item.productName),
            trailing: Text('${item.quantity} x ${item.price.toStringAsFixed(0)} ₽'),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
