import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_success_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoadProfileDataUsecase {
  final AuthRepository _repository;

  LoadProfileDataUsecase(this._repository);

  Future<Either<Failure, LoginSuccessData>> execute() {
    return _repository.getProfileData();
  }
}