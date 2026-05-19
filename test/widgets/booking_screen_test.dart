import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_club_mobile/screens/booking_screen.dart';

void main() {
  group('BookingScreen Widget Tests', () {
    testWidgets('BookingScreen displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      // Wait for initial render
      await tester.pump();

      // Check if all UI elements are present
      expect(find.text('Бронирование ПК'), findsOneWidget);
      expect(find.text('Выберите ПК:'), findsOneWidget);
      expect(find.text('Дата и время:'), findsOneWidget);
      expect(find.text('Продолжительность (часы):'), findsOneWidget);
      expect(find.text('ЗАБРОНИРОВАТЬ'), findsOneWidget);
    });

    testWidgets('Duration validation works for empty field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      await tester.pump();

      // Try to submit form without entering duration
      await tester.tap(find.text('ЗАБРОНИРОВАТЬ'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Введите продолжительность'), findsOneWidget);
    });

    testWidgets('Duration validation works for invalid values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      await tester.pump();

      // Find duration field and enter invalid duration
      final durationField = find.byType(TextFormField);
      await tester.enterText(durationField, '0');

      // Try to submit form
      await tester.tap(find.text('ЗАБРОНИРОВАТЬ'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Продолжительность должна быть от 1 до 12 часов'), findsOneWidget);
    });

    testWidgets('Duration validation works for maximum hours', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      await tester.pump();

      // Find duration field and enter too high duration
      final durationField = find.byType(TextFormField);
      await tester.enterText(durationField, '15');

      // Try to submit form
      await tester.tap(find.text('ЗАБРОНИРОВАТЬ'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Продолжительность должна быть от 1 до 12 часов'), findsOneWidget);
    });

    testWidgets('Date picker opens when tapping date field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      await tester.pump();

      // Find and tap date field
      final dateField = find.byIcon(Icons.calendar_today);
      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Should open date picker
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Valid duration passes validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookingScreen(),
        ),
      );

      await tester.pump();

      // Enter valid duration
      final durationField = find.byType(TextFormField);
      await tester.enterText(durationField, '2');

      // Try to submit form
      await tester.tap(find.text('ЗАБРОНИРОВАТЬ'));
      await tester.pump();

      // Should not show duration validation error
      expect(find.text('Продолжительность должна быть от 1 до 12 часов'), findsNothing);
      expect(find.text('Введите продолжительность'), findsNothing);
    });
  });
}