import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_providers.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/cache_service.dart';
import 'services/client_api_service.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/smooth_scroll.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('ru', null);
    await LocalStorageService.init();
    await CacheService.init();
    await ClientApiService().restoreSession();

    // Очищаем истекший кэш при запуске
    await CacheService.clearExpired();

    final authToken = await LocalStorageService.getAuthToken();

    runApp(PcClubApp(isLoggedIn: authToken != null && authToken.isNotEmpty));
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Ошибка запуска: $e'),
          ),
        ),
      ),
    );
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
            title: 'Личный кабинет ПК-клуба',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Применяем кастомное поведение скролла глобально
            scrollBehavior: CustomScrollBehavior(),
            home: isLoggedIn ? const MainScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
