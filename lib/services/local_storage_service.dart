import 'package:hive_flutter/hive_flutter.dart';
import '../models/client_profile.dart';

class LocalStorageService {
  static const String _settingsBoxName = 'settings';
  static const String _clientIdKey = 'client_id';
  static const String _passwordPrefix = 'password_';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveClientId(int id) async {
    var box = Hive.box(_settingsBoxName);
    await box.put(_clientIdKey, id);
  }

  static int? getClientId() {
    var box = Hive.box(_settingsBoxName);
    return box.get(_clientIdKey);
  }

  static Future<void> clearSession() async {
    var box = Hive.box(_settingsBoxName);
    await box.delete(_clientIdKey);
  }

  static Future<void> saveClientPassword(String phone, String password) async {
    var box = Hive.box(_settingsBoxName);
    await box.put('$_passwordPrefix$phone', password);
  }

  static String? getClientPassword(String phone) {
    var box = Hive.box(_settingsBoxName);
    return box.get('$_passwordPrefix$phone');
  }

  static Future<void> saveClientProfile(ClientProfile profile) async {
    var box = await Hive.openBox('client_profiles');
    await box.put(profile.id, profile.toJson());
  }

  static Future<ClientProfile> getClientProfileFromBackup(int clientId) async {
    var box = await Hive.openBox('client_profiles');
    var data = box.get(clientId);
    if (data != null) {
      return ClientProfile.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('No backup found for client $clientId');
  }
}
