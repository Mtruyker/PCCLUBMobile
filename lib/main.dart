import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await initializeDateFormatting('ru', null);
    await LocalStorageService.init();
    
    final clientId = LocalStorageService.getClientId();
    
    runApp(MyApp(isLoggedIn: clientId != null));
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(body: Center(child: Text('Ошибка запуска: $e'))),
    ));
  }
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) => 
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Личный кабинет ПК‑клуба',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        // Исправлено: заменено на CardThemeData согласно ошибке
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
      ),
      
      themeMode: _themeMode,
      home: widget.isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
