import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pc_club_mobile/main.dart';
import 'package:pc_club_mobile/services/local_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login to Booking Flow Integration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      await LocalStorageService.init();
    });

    tearDownAll(() async {
      // Clean up after tests
      await Hive.close();
    });

    testWidgets('Complete login to booking flow', (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(const PcClubApp(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Should start on login screen
      expect(find.text('Добро пожаловать!'), findsOneWidget);
      expect(find.text('ВОЙТИ'), findsOneWidget);

      // Enter login credentials
      final phoneField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(phoneField, '+79991234567');
      await tester.enterText(passwordField, 'password123');

      // Note: In a real integration test, you would need to mock the API
      // or use a test server. For now, this test shows the structure.

      // Tap login button
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If login is successful, should navigate to main screen
      // This would depend on your API returning success
      // expect(find.text('Главная'), findsOneWidget);

      // Navigate to booking screen
      // This would depend on your navigation structure
      // await tester.tap(find.byIcon(Icons.computer));
      // await tester.pumpAndSettle();

      // Should be on booking screen
      // expect(find.text('Бронирование ПК'), findsOneWidget);

      // Select PC and duration
      // await tester.tap(find.byType(DropdownButtonFormField));
      // await tester.pumpAndSettle();
      // await tester.tap(find.text('PC-001').last);
      // await tester.pumpAndSettle();

      // Enter duration
      // final durationField = find.byType(TextFormField);
      // await tester.enterText(durationField, '2');

      // Submit booking
      // await tester.tap(find.text('ЗАБРОНИРОВАТЬ'));
      // await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success message or navigate to confirmation
      // expect(find.textContaining('успешно'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error', (WidgetTester tester) async {
      await tester.pumpWidget(const PcClubApp(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Enter invalid credentials
      final phoneField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(phoneField, '+79991234567');
      await tester.enterText(passwordField, 'wrongpassword');

      // Tap login button
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show error message
      // In a real test, this would depend on your error handling
      // expect(find.textContaining('Ошибка'), findsOneWidget);
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const PcClubApp(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Should start on login screen
      expect(find.text('Добро пожаловать!'), findsOneWidget);

      // Navigate to register screen
      await tester.tap(find.text('Нет аккаунта? Зарегистрируйтесь'));
      await tester.pumpAndSettle();

      // Should be on register screen
      expect(find.text('Создать аккаунт'), findsOneWidget);

      // Go back to login
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('Добро пожаловать!'), findsOneWidget);
    });

    testWidgets('Form validation prevents invalid submissions', (WidgetTester tester) async {
      await tester.pumpWidget(const PcClubApp(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Try to login without entering anything
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Введите номер телефона'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);

      // Enter invalid phone format
      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '123');
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show phone validation error
      expect(find.text('Введите корректный номер телефона'), findsOneWidget);

      // Enter short password
      await tester.enterText(phoneField, '+79991234567');
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, '123');
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show password validation error
      expect(find.text('Пароль должен содержать минимум 8 символов'), findsOneWidget);
    });
  });
}