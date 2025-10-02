// lib/core/utils/car_channel.dart
import 'package:flutter/services.dart';
import '../injection.dart';
import '../local_services/local_services.dart';
import '../constants/constants.dart';
import '../../features/authentication/data/datasources/employee_local_data_source.dart';
import '../sync/offsite_event_bus.dart';  // make sure this import is here
import 'car_bridge.dart';

class CarChannel {
  static const MethodChannel _car = MethodChannel('ae.gov.moet.moethub/car');

  // Phone -> Car broadcast (you already used this)
  static const MethodChannel _ui  = MethodChannel('ae.gov.moet.moethub/car_ui');

  // Native -> Dart (phone side): receive APP_RESYNC
  static const MethodChannel _app = MethodChannel('ae.gov.moet.moethub/app');

  static bool _registered = false;

  static Future<void> register() async {
    if (_registered) return;
    _registered = true;

    _car.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'ping': return true;
        case 'isLoggedIn':
          try { final p = await getIt<EmployeeLocalDataSource>().getProfile(); return p != null; }
          catch (_) { return false; }
        case 'needMoodToday': return CarBridge.needMoodToday();
        case 'checkIn': return await CarBridge.handleCheckIn();
        case 'checkInWithMood':
          final map = (call.arguments as Map?) ?? const {};
          final mood = map['mood'] as String?;
          if (mood == null || mood.isEmpty) return false;
          return await CarBridge.handleCheckInWithMood(mood);
        case 'getCheckInsMillis':
          final local = getIt<LocalService>();
          return local.getMillisList(checkIns) ?? const <int>[];
        default: return null;
      }
    });

    // Native -> Dart (phone UI should refresh now)
    _app.setMethodCallHandler((call) async {
      if (call.method == 'appResync') {
        getIt<OffsiteEventBus>().notifyChanged();
        return true;
      }
      return null;
    });
  }

  /// Phone -> Car: ask the Android Auto UI to re-sync now.
  static Future<void> notifyCarToResync() async {
    try { await _ui.invokeMethod('resyncCar'); } catch (_) {}
  }
}
