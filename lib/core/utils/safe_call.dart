import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

Future<Either<Failure, R>> safeCall<R>(
    Future<Response> Function() request,
    R Function(Response) mapper,
    ) async {
  try {
    final res = await request();
    return Right(mapper(res));
  } on DioException catch (dioErr) {
    final failure = dioErr.error is Failure
        ? dioErr.error as Failure
        : ServerFailure(dioErr.message ?? "Connection Error");
    return Left(failure);
  } catch (_) {
    return const Left(ServerFailure('An unexpected error occurred.'));
  }
}
