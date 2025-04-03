import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/login_success_model.dart';
import '../../../authentication/domain/repositories/login_repository.dart';




@injectable
class LoginUseCase {
  final LoginRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, LoginSuccessData>> execute(String phone, String password) {
    return _repository.login(phone, password);
  }
}