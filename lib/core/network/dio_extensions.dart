import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../errors/failures.dart';
import '../utils/safe_call.dart';

extension DioX on Dio {
  Future<Either<Failure, R>> safe<R>(
      Future<Response> Function() request,
      R Function(Response) mapper,
      ) => safeCall(request, mapper);
}