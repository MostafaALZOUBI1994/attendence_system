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
    final prefs = _preferences;
    final stored = prefs.getStringList(key);
    if (stored == null) return null;


    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    final todayStrings = <String>[];
    final todayMillis = <int>[];

    for (var s in stored) {
      final ms = int.tryParse(s);
      if (ms != null && ms >= startOfToday && ms <= endOfToday) {
        todayStrings.add(s);
        todayMillis.add(ms);
      }
    }

    if (todayStrings.length != stored.length) {
      prefs.setStringList(key, todayStrings);
    }

    return todayMillis;
  }



  Future<bool> saveMillisList(String key, List<int> millisList) async {
    final stringList = millisList.map((ms) => ms.toString()).toList(growable: false);
    return _preferences.setStringList(key, stringList);
  }

  Future<void> saveLocale(Locale locale) async {
    // only save “en” or “ar”
    await save(localeKey, locale.languageCode);
    Intl.defaultLocale = locale.languageCode;
  }

  Locale getSavedLocale() {
    final code = _preferences.getString(localeKey);
    if (code != null && (code == 'en' || code == 'ar')) {
      return Locale(code);
    }
    // fallback from device
    final deviceLang = ui.PlatformDispatcher.instance.locale.languageCode;
    final chosen = (deviceLang == 'ar') ? const Locale('ar') : const Locale('en');
    saveLocale(chosen);
    return chosen;
  }
}
