import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_success_model.dart';
import '../repositories/login_repository.dart';



@injectable
class LoginUseCase {
  final LoginRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, LoginSuccessData>> execute(String phone, String password) {
    return _repository.login(phone, password);
  }
}