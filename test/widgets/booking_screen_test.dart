import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pc_club_mobile/screens/booking_screen.dart';
import 'package:pc_club_mobile/utils/error_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ru');
  });

  group('BookingScreen Widget Tests', () {
    testWidgets('BookingScreen displays current booking UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            loadAvailablePcs: () async => ['PC-01', 'PC-02'],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Бронирование'), findsOneWidget);
      expect(find.text('Выберите компьютер:'), findsOneWidget);
      expect(find.text('Дата и время:'), findsOneWidget);
      expect(find.text('Длительность:'), findsOneWidget);
      expect(find.text('Подтвердить бронирование'), findsOneWidget);
      expect(find.text('PC-01'), findsOneWidget);
      expect(find.text('1 ч.'), findsAtLeastNWidgets(1));
    });

    testWidgets('Initial PC name is matched by digits', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            initialPcName: 'Стол 1',
            loadAvailablePcs: () async => ['PC-01', 'PC-02'],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PC-01'), findsOneWidget);
    });

    testWidgets('Date picker opens when tapping date tile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            loadAvailablePcs: () async => ['PC-01'],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Дата'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Shows empty state when no PCs are available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            loadAvailablePcs: () async => [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Нет свободных компьютеров'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Shows retry state when loading PCs fails', (WidgetTester tester) async {
      var attempts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingScreen(
            loadAvailablePcs: () async {
              attempts++;
              if (attempts == 1) {
                throw Exception('network failed');
              }
              return ['PC-05'];
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Не удалось загрузить список компьютеров'), findsWidgets);
      expect(find.text('Повторить'), findsOneWidget);

      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();

      expect(find.text('PC-05'), findsOneWidget);
      expect(find.byType(ErrorStateWidget), findsNothing);
    });
  });
}
