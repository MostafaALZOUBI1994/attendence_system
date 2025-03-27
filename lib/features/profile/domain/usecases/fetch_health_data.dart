import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/health_model.dart';
import '../repositories/health_repository.dart';

@injectable
class FetchHealthData {
  final HealthRepository repository;

  FetchHealthData(this.repository);

  Future<Either<Failure, HealthData>> call() async {
    return await repository.fetchHealthData();
  }
}