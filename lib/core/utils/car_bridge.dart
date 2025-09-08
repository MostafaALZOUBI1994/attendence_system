import 'package:flutter/foundation.dart';
import '../../features/attendence/domain/repositories/attendence_repository.dart';
import '../../features/attendence/presentation/bloc/attendence_bloc.dart';
import '../injection.dart';


class CarBridge {
  static Future<bool> handleCheckIn() async {
    try {
      await getIt<AttendenceRepository>().checkIn();
      final bloc = getIt<AttendenceBloc>();
      bloc.add(const AttendenceEvent.loadData());
      return true;
    } catch (e, st) {
      debugPrint('CarBridge.handleCheckIn failed: $e\n$st');
      return false;
    }
  }
}