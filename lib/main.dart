import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('ru', null);
    await LocalStorageService.init();

    final clientId = LocalStorageService.getClientId();

    runApp(PcClubApp(isLoggedIn: clientId != null));
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(body: Center(child: Text('Ошибка запуска: $e'))),
    ));
  }
}

class PcClubApp extends StatelessWidget {
  final bool isLoggedIn;

  const PcClubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Личный кабинет ПК‑клуба',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: isLoggedIn ? const MainScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}