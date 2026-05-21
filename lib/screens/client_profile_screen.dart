import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client_profile.dart';
import '../providers/theme_provider.dart';
import '../services/client_api_service.dart';
import '../utils/error_handler.dart';
import 'active_bookings_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'session_history_screen.dart';
import 'support_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  late final ClientApiService _apiService;
  ClientProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ClientApiService>();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getClientProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ErrorHandler.show(context, e, customMessage: 'Не удалось загрузить профиль');
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Выход'),
            content: const Text('Выйти из аккаунта?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Выйти', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) {
      return;
    }

    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    await _apiService.clearAuthToken();

    if (mounted) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Text(
              'Профиль не найден',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: loadProfile,
              child: const Text('Попробовать снова'),
            ),
          ),
        ],
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: Text(
                  _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile!.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _profile!.phone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBalanceCard(),
          const SizedBox(height: 24),
          const Text(
            'Настройки и услуги',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            icon: Icons.event_available,
            title: 'Мои бронирования',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActiveBookingsScreen(),
                ),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.shopping_bag_outlined,
            title: 'История заказов',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.history,
            title: 'История сессий',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SessionHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuTile(
            icon: isDark ? Icons.light_mode : Icons.dark_mode,
            title: isDark ? 'Светлая тема' : 'Темная тема',
            onTap: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          _buildMenuTile(
            icon: Icons.contact_support_outlined,
            title: 'Поддержка',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.exit_to_app,
            title: 'Выйти из аккаунта',
            onTap: _handleLogout,
            isDestructive: true,
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      color: isDestructive
          ? Colors.red.withValues(alpha: 0.1)
          : Theme.of(context).cardTheme.color ?? Colors.grey.withValues(alpha: 0.05),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Контактная информация',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(_profile!.phone),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(_profile!.email.isEmpty ? 'Не указан' : _profile!.email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Текущий баланс',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '${_profile!.balance.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _showTopUpDialog,
            child: const Text('Пополнить'),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пополнение баланса'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Сумма (₽)',
            suffixText: '₽',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Перенаправление на оплату...')),
              );
            },
            child: const Text('Пополнить'),
          ),
        ],
      ),
    );
  }
}
