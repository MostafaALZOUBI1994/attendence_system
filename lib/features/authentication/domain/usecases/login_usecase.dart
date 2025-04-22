import 'package:attendence_system/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/login_success_model.dart';


@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, LoginSuccessData>> execute(String phone, String password) {
    return _repository.login(phone, password);
  }
}