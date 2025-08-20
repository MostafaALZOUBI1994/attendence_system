import 'package:flutter/foundation.dart';
import '../../features/attendence/domain/repositories/attendence_repository.dart';
import '../injection.dart';


class CarBridge {
  static Future<bool> handleCheckIn() async {
    try {
      await getIt<AttendenceRepository>().checkIn();
      return true;
    } catch (e, st) {
      debugPrint('CarBridge.handleCheckIn failed: $e\n$st');
      return false;
    }
  }
}