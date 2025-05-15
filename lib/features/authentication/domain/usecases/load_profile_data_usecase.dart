import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoadProfileDataUsecase {
  final AuthRepository _repository;

  LoadProfileDataUsecase(this._repository);

  Future<Either<Failure, Employee>> execute() {
    return _repository.getProfileData();
  }
}