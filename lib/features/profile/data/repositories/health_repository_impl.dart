import 'package:health/health.dart';
import 'package:dartz/dartz.dart';
import 'package:attendence_system/features/profile/domain/repositories/health_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/health_model.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  final Health _health = Health();

  @override
  Future<Either<Failure, HealthData>> fetchHealthData() async {
    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.SLEEP_IN_BED,
      ];

      bool hasPermissions = await _health.requestAuthorization(types);
      if (!hasPermissions) return const Left(InvalidInputFailure("Don't have permission"));

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(types: types,startTime: startOfDay,endTime: now);

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
