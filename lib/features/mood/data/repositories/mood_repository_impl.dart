import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../domain/entities/employee_mood.dart';
import '../../domain/repositories/mood_repository.dart';



@LazySingleton(as: MoodRepository)
class MoodRepositoryImpl implements MoodRepository {
  final Dio _dio;
  final EmployeeLocalDataSource _local;

  MoodRepositoryImpl(this._dio, this._local);

  final _postFmt = DateFormat('yyyy/MM/dd');
  final _getFmt  = DateFormat('yyyy-MM-dd');



  @override
  Future<Either<Failure, Unit>> postMood({
    required int moodId,
    required String mood,
    String? note,
    DateTime? date,
  }) async {
    try {
      final empId = await _local.getEmployeeId();
      final d = date ?? DateTime.now();

      await _dio.post(
        '/PostEmployeeMood',
        data: {
          'EmployeeId': empId,
          'MoodId': moodId,
          'Mood': mood,
          'MoodNote': note ?? '',
          'Date': _postFmt.format(d),
        },
      );
      return const Right(unit);
    } on StateError catch (e) {

      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeMood>>> getMoodHistory({
    int? employeeId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final empId = await _local.getEmployeeId();

      final res = await _dio.get(
        'GetEmployeeMood',
        queryParameters: {
          'employeeId': empId,
          'fromDate': _getFmt.format(from),
          'toDate': _getFmt.format(to),
        },
      );

      final data = res.data;
      if (data is! List) {
        return Left(ServerFailure('Unexpected response shape'));
      }

      final list = data.map<EmployeeMood>((e) {
        final moodId = (e['MoodId'] ?? e['moodId']) as int;
        final mood   = (e['Mood'] ?? e['mood']) as String;
        final note   = (e['MoodNote'] ?? e['moodNote']) as String?;
        final raw    = (e['Date'] ?? e['date']) as String;

        final norm = raw.replaceAll('/', '-');
        final dt   = DateTime.tryParse(norm) ?? DateTime.now();

        return EmployeeMood(
          moodId: moodId,
          mood: mood,
          note: note,
          date: dt,
        );
      }).toList();

      return Right(list);
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}