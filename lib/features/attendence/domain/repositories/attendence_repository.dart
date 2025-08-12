import 'package:moet_hub/features/attendence/domain/entities/today_status.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AttendenceRepository {
  Future<Either<Failure, TodayStatus>> getTodayStatus();
  Future<Either<Failure, String>> checkIn();
}
