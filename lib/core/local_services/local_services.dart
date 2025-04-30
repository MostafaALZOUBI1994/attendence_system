import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../constants/constants.dart';

@singleton
class LocalService {
  final SharedPreferences _preferences;
  LocalService(this._preferences);

  Future<void> save(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? get(String key) {
    return _preferences.getString(key);
  }

  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clearAll() async {
    await _preferences.clear();
  }

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

  Future<bool> saveMillisList(String key, List<int> millisList) async {
    final stringList = millisList.map((ms) => ms.toString()).toList(growable: false);
    return _preferences.setStringList(key, stringList);
  }

  Future<void> saveLocale(Locale locale) async {
    final localeString = '${locale.languageCode}-${locale.countryCode ?? ''}';
    await save(localeKey, localeString);
    Intl.defaultLocale = locale.toString();
  }



  Locale getSavedLocale() {
    final localeString = _preferences.getString(localeKey);

    if (localeString != null && localeString.isNotEmpty) {
      final parts = localeString.split('-');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
      return Locale(parts[0]);
    }

    final device = ui.PlatformDispatcher.instance.locale;
    final Locale chosen = (device.languageCode == 'ar')
        ? const Locale('ar', 'AE')
        : const Locale('en', 'US');

    saveLocale(chosen);
    return chosen;
  }


  String get currentLanguageCode => getSavedLocale().languageCode;
}
