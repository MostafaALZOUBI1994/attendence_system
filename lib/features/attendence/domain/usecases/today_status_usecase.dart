import 'package:moet_hub/features/attendence/domain/repositories/attendence_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/today_status.dart';


@injectable
class GetTodayStatusUseCase {
  final AttendenceRepository _repository;

  GetTodayStatusUseCase(this._repository);

  Future<Either<Failure, TodayStatus>> execute() {
    return _repository.getTodayStatus();
  }
}