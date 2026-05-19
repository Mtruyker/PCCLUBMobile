import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/client_api_service.dart';
import '../utils/error_handler.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int clientId;

  const OrderHistoryScreen({super.key, required this.clientId});

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

      final orders = await _apiService.getClientOrders(widget.clientId);

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.show(context, e);
      }
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
                          Text('Вы еще ничего не заказывали',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return _buildOrderCard(order);
                      },
                    ),
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
