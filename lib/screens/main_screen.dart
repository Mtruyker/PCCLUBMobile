import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'client_profile_screen.dart';
import 'catalog_screen.dart';
import 'news_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int? _clientId;

  @override
  void initState() {
    super.initState();
    // Получаем ID текущего пользователя из локального хранилища
    _clientId = LocalStorageService.getClientId();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Список экранов инициализируем в build, так как _clientId уже известен
    if (_clientId == null) {
      return const LoginScreen();
    }

    final List<Widget> screens = [
      const NewsScreen(),
      const CatalogScreen(),
      ClientProfileScreen(clientId: _clientId!),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Новости',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.computer), label: 'Каталог'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
