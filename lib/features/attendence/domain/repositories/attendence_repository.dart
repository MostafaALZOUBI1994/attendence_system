import 'package:attendence_system/features/attendence/domain/entities/today_status.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AttendenceRepository {
  Future<Either<Failure, TodayStatus>> getTodayStatus();
}
