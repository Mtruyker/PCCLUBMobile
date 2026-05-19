import 'package:flutter_test/flutter_test.dart';
import 'package:pc_club_mobile/models/client_profile.dart';

void main() {
  group('ClientProfile Model Tests', () {
    test('ClientProfile creation with valid data', () {
      final profile = ClientProfile(
        id: 1,
        name: 'John Doe',
        phone: '+79991234567',
        email: 'john@example.com',
        balance: 500.0,
      );

      expect(profile.id, 1);
      expect(profile.name, 'John Doe');
      expect(profile.phone, '+79991234567');
      expect(profile.email, 'john@example.com');
      expect(profile.balance, 500.0);
    });

    test('ClientProfile JSON serialization', () {
      final profile = ClientProfile(
        id: 1,
        name: 'John Doe',
        phone: '+79991234567',
        email: 'john@example.com',
        balance: 500.0,
      );

      final json = profile.toJson();
      expect(json['id'], 1);
      expect(json['name'], 'John Doe');
      expect(json['phone'], '+79991234567');
      expect(json['email'], 'john@example.com');
      expect(json['balance'], 500.0);
    });

    test('ClientProfile JSON deserialization', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'phone': '+79991234567',
        'email': 'john@example.com',
        'balance': 500.0,
      };

      final profile = ClientProfile.fromJson(json);
      expect(profile.id, 1);
      expect(profile.name, 'John Doe');
      expect(profile.phone, '+79991234567');
      expect(profile.email, 'john@example.com');
      expect(profile.balance, 500.0);
    });

    test('ClientProfile with zero balance', () {
      final profile = ClientProfile(
        id: 2,
        name: 'Jane Doe',
        phone: '+79997654321',
        email: 'jane@example.com',
        balance: 0.0,
      );

      expect(profile.balance, 0.0);
    });

    test('ClientProfile with negative balance', () {
      final profile = ClientProfile(
        id: 3,
        name: 'Bob Smith',
        phone: '+79995555555',
        email: 'bob@example.com',
        balance: -50.0,
      );

      expect(profile.balance, -50.0);
    });
  });
}