// lib/core/local_services/car_entry.dart
// Android Auto entrypoint: exposes the same logic as CarPlay via MethodChannel.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_data;
import 'package:intl/intl.dart' as intl;
import '../injection.dart';
import '../utils/car_bridge.dart';
import '../local_services/local_services.dart';
import '../constants/constants.dart';
import 'package:moet_hub/features/authentication/data/datasources/employee_local_data_source.dart';

const _channelName = 'ae.gov.moet.moethub/car';

@pragma('vm:entry-point') // keep this entrypoint in AOT
Future<void> carEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[carEntryPoint] isolate started');

  // Initialize DI in this isolate as well.
  try { await configureDependencies(); } catch (e) {
    debugPrint('[carEntryPoint] DI init error: $e');
  }
  try {
    // if you store the user’s locale already:
    final saved = getIt<LocalService>().getSavedLocale(); // Locale('en') / Locale('ar')
    final lc = saved.languageCode;           // "en" or "ar"
    await intl_data.initializeDateFormatting(lc);
    intl.Intl.defaultLocale = lc;
  } catch (_) {
    // safe fallback
    await intl_data.initializeDateFormatting('en');
    intl.Intl.defaultLocale = 'en';
  }

  const channel = MethodChannel(_channelName);
  debugPrint('[carEntryPoint] MethodChannel($_channelName) created');

  channel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'ping':
        return true;
      case 'isLoggedIn':
        try {
          final p = await getIt<EmployeeLocalDataSource>().getProfile();
          return p != null;
        } catch (e) {
          debugPrint('[carEntryPoint] isLoggedIn error: $e');
          return false;
        }
      case 'needMoodToday':
        try {
          return CarBridge.needMoodToday();
        } catch (_) {
          return false;
        }
      case 'getCheckInsMillis':
        try {
          final local = getIt<LocalService>();
          final list = local.getMillisList(checkIns) ?? const <int>[];
          return List<int>.from(list);
        } catch (_) {
          return const <int>[];
        }
      case 'checkIn':
        try {
          return await CarBridge.handleCheckIn() == true;
        } catch (_) {
          return false;
        }
      case 'checkInWithMood':
        try {
          final mood = (call.arguments is Map && (call.arguments as Map)['mood'] is String)
              ? (call.arguments as Map)['mood'] as String
              : '';
          return await CarBridge.handleCheckInWithMood(mood) == true;
        } catch (_) {
          return false;
        }
      default:
        throw PlatformException(code: 'not_implemented', message: call.method);
    }
  });

  debugPrint('[carEntryPoint] MethodCallHandler attached and ready');

  // Keep isolate alive
  while (true) {
    await Future<void>.delayed(const Duration(days: 1));
  }
}