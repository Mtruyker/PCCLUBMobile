import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../services/client_api_service.dart';
import '../utils/error_handler.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final ClientApiService _apiService = ClientApiService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      final orders = await _apiService.getClientOrders();

      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ErrorHandler.show(context, e, customMessage: 'Не удалось загрузить заказы');
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'Новый';
      case 'paid':
        return 'Оплачен';
      case 'preparing':
        return 'Готовится';
      case 'done':
        return 'Готов';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'paid':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'new':
      default:
        return Colors.grey;
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
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Вы еще ничего не заказывали',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_orders[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.fastfood, color: Colors.white, size: 20),
        ),
        title: Text(
          'Заказ #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(order.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.totalAmount.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              _statusLabel(order.status),
              style: TextStyle(fontSize: 10, color: statusColor),
            ),
          ],
        ),
        children: [
          const Divider(),
          ...order.items.map(
            (item) => ListTile(
              dense: true,
              title: Text(item.productName),
              trailing: Text('${item.quantity} x ${item.price.toStringAsFixed(0)} ₽'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
