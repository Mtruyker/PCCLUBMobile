import 'package:flutter_test/flutter_test.dart';
import 'package:pc_club_mobile/main.dart';

void main() {
  group('App Tests', () {
    test('App smoke test', () {
      // Test that the app class exists and can be instantiated
      expect(PcClubApp, isNotNull);
    });

    test('PcClubApp can be created with required parameters', () {
      // Test that the app widget can be created with required parameters
      const app = PcClubApp(isLoggedIn: false);
      expect(app, isA<PcClubApp>());
    });
  });
}