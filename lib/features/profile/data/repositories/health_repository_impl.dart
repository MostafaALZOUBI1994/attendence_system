import 'package:health/health.dart';
import 'package:dartz/dartz.dart';
import 'package:attendence_system/features/profile/domain/repositories/health_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/health_model.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  final Health _health = Health();

  @override
  Future<Either<Failure, HealthData>> fetchHealthData() async {
    try {
      await Permission.activityRecognition.request();

      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.SLEEP_ASLEEP,
      ];

      bool hasPermissions = await _health.requestAuthorization(types);
      if (!hasPermissions) {
        return const Left(InvalidInputFailure("Permission denied"));
      }
      final now = DateTime.now();
      DateTime nowLocal = DateTime.now().toLocal();
      DateTime yesterdayLocal = nowLocal.subtract(const Duration(days: 1));
      DateTime startOfYesterdayLocal = DateTime(
        yesterdayLocal.year,
        yesterdayLocal.month,
        yesterdayLocal.day,
      );

      final healthData = await _health.getHealthDataFromTypes(
          types: types, startTime: startOfYesterdayLocal, endTime: now);

      int steps = 0;
      int heartRate = 0;
      double caloriesBurned = 0;
      double sleepDuration = 0;

      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          final numericValue = (data.value as NumericHealthValue);

          switch (data.type) {
            case HealthDataType.STEPS:
              steps += numericValue.numericValue.toInt();
              break;
            case HealthDataType.HEART_RATE:
              heartRate = numericValue.numericValue.toInt();
              break;
            case HealthDataType.ACTIVE_ENERGY_BURNED:
              caloriesBurned = numericValue.numericValue.toDouble();
              break;
            case HealthDataType.SLEEP_IN_BED:
              sleepDuration = numericValue.numericValue.toDouble();
              break;
            default:
              break;
          }
        }
      }

      return Right(HealthData(
        steps: steps,
        heartRate: heartRate,
        caloriesBurned: caloriesBurned,
        sleepDuration: sleepDuration,
      ));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
