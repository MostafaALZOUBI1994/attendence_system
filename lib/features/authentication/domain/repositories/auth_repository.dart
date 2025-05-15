import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee.dart';

abstract class AuthRepository {
  Future<Either<Failure, Employee>> login(String phone, String password);
  Future<Either<Failure, bool>> signOut();
  Future<Either<Failure, Employee>> getProfileData();
}
