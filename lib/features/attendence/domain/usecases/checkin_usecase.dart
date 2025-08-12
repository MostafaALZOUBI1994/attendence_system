

import 'package:moet_hub/features/attendence/domain/repositories/attendence_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';

@injectable
class CheckinUsecase {
  final AttendenceRepository _repository;
  CheckinUsecase(this._repository);

  Future<Either<Failure, String>> execute() {
    return _repository.checkIn();
  }
}