import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_3/main.dart';
import 'package:flutter_application_3/screens/login_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We use a mock or just test the structure since it tries to init Hive and API
    // In a real scenario, we'd mock the services.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that the title is present in the MaterialApp (not visible on screen usually but in the widget tree)
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Личный кабинет ПК‑клуба');

    // Verify that LoginScreen is the home for logged-out users.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
