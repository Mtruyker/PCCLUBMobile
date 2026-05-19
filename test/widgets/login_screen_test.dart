import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_club_mobile/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Check if all UI elements are present
      expect(find.text('Добро пожаловать!'), findsOneWidget);
      expect(find.text('Войдите в свой аккаунт'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Phone and password fields
      expect(find.text('ВОЙТИ'), findsOneWidget);
      expect(find.text('Нет аккаунта? Зарегистрируйтесь'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find password visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility_off);
      expect(visibilityToggle, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Icon should change to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Form validation shows errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Try to submit form without entering anything
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Введите номер телефона'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('Phone field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find phone field and enter invalid phone
      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '123');

      // Try to submit form
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Введите корректный номер телефона'), findsOneWidget);
    });

    testWidgets('Password field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Enter valid phone but short password
      final phoneField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(phoneField, '+79991234567');
      await tester.enterText(passwordField, '123');

      // Try to submit form
      await tester.tap(find.text('ВОЙТИ'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Пароль должен содержать минимум 8 символов'), findsOneWidget);
    });
  });
}