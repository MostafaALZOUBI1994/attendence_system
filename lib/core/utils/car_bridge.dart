// lib/core/utils/car_bridge.dart
import '../../features/attendence/domain/repositories/attendence_repository.dart';
import '../constants/constants.dart';
import '../injection.dart';
import 'package:flutter/foundation.dart';

import '../local_services/local_services.dart';

class CarBridge {
  // Mood needed if there are no offsite check-ins today
  static bool needMoodToday() {
    final local = getIt<LocalService>();
    final list = local.getMillisList(checkIns) ?? const <int>[];
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    return !list.any((ms) => ms >= start && ms < end);
  }

  static Future<bool> handleCheckIn() async {
    try {
      final res = await getIt<AttendenceRepository>().checkIn();
      return res.isRight(); // Either<Failure,String>
    } catch (e, st) {
      debugPrint('CarBridge.handleCheckIn error: $e\n$st');
      return false;
    }
  }

  static Future<bool> handleCheckInWithMood(String mood) async {
    // If mood goes to backend separately: add a dedicated repo call here.
    // For now, calling the same checkIn endpoint.
    return handleCheckIn();
  }
}