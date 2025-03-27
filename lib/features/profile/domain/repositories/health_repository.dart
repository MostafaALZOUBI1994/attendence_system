import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/health_model.dart';


abstract class HealthRepository {
  Future<Either<Failure, HealthData>> fetchHealthData();
}
