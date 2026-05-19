import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/client_profile.dart';

class LocalStorageService {
  static const String _settingsBoxName = 'settings';
  static const String _profilesBoxName = 'client_profiles';
  static const String _clientIdKey = 'client_id';
  static const String _tokenKey = 'auth_token';

  static Box? _settingsBox;
  static Box? _profilesBox;
  static FlutterSecureStorage? _secureStorage;

  static Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _profilesBox = await Hive.openBox(_profilesBoxName);
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  static Box get _box {
    if (_settingsBox == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  static Box get _profilesBoxInstance {
    if (_profilesBox == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _profilesBox!;
  }

  static Future<void> saveClientId(int id) async {
    await _box.put(_clientIdKey, id);
  }

  static int? getClientId() {
    return _box.get(_clientIdKey);
  }

  static Future<void> saveAuthToken(String token) async {
    await _secureStorage?.write(key: _tokenKey, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _secureStorage?.read(key: _tokenKey);
  }

  static Future<void> clearSession() async {
    await _box.delete(_clientIdKey);
    await _secureStorage?.delete(key: _tokenKey);
  }

  static Future<void> clearAll() async {
    await _box.clear();
    await _profilesBoxInstance.clear();
    await _secureStorage?.deleteAll();
  }

  static Future<void> saveClientProfile(ClientProfile profile) async {
    await _profilesBoxInstance.put(profile.id, profile.toJson());
  }

  static Future<ClientProfile?> getClientProfileFromBackup(int clientId) async {
    var data = _profilesBoxInstance.get(clientId);
    if (data != null) {
      return ClientProfile.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}