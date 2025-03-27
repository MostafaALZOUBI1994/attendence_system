import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_success_model.dart';

abstract class LoginRepository {
  Future<Either<Failure, LoginSuccessData>> login(String phone, String password);
}
