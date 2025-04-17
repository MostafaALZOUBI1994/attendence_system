import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class LocalService {
  final SharedPreferences _preferences;
  LocalService(this._preferences);

  Future<void> save(String key, String value) {
    return _preferences.setString(key, value);
  }

  String? get(String key) {
    return _preferences.getString(key);
  }

  Future<void> delete(String key) {
    return _preferences.remove(key);
  }

  Future<void> clearAll() => _preferences.clear();

  Future<bool> addMillis(String key, int millis) async {
    final existing = getMillisList(key) ?? <int>[];
    existing.add(millis);
    return saveMillisList(key, existing);
  }

  List<int>? getMillisList(String key) {
    final stringList = _preferences.getStringList(key);
    if (stringList == null) return null;
    return stringList
        .map((s) => int.tryParse(s))
        .where((i) => i != null)
        .cast<int>()
        .toList();
  }

  Future<bool> saveMillisList(String key, List<int> millisList) {
    final stringList = millisList.map((ms) => ms.toString()).toList(growable: false);
    return _preferences.setStringList(key, stringList);
  }
}