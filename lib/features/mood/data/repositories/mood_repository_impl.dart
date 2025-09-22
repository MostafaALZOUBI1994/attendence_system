import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee_mood.dart';
import '../../domain/repositories/mood_repository.dart';

@LazySingleton(as: MoodRepository)
class MoodRepositoryImpl implements MoodRepository {
  final Dio _dio;
  MoodRepositoryImpl(this._dio);


  final _postFmt = DateFormat('yyyy/MM/dd');
  final _getFmt  = DateFormat('yyyy-MM-dd');

  @override
  Future<Either<Failure, Unit>> postMood({
    required int employeeId,
    required int moodId,
    required String mood,
    String? note,
    DateTime? date,
  }) async {
    try {
      final d = date ?? DateTime.now();
      await _dio.post(
        '/api/lgt/PostEmployeeMood',
        data: {
          'EmployeeId': employeeId,
          'MoodId': moodId,
          'Mood': mood,
          'MoodNote': note ?? '',
          'Date': _postFmt.format(d),
        },
      );
      return const Right(unit);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return Left(ServerFailure( msg));
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeMood>>> getMoodHistory({
    required int employeeId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await _dio.get(
        '/api/lgt/GetEmployeeMood',
        queryParameters: {
          'employeeId': employeeId,
          'fromDate': _getFmt.format(from),
          'toDate': _getFmt.format(to),
        },
      );

      final data = res.data;
      if (data is! List) {
        return Left(ServerFailure( 'Unexpected response shape'));
      }

      final list = data.map<EmployeeMood>((e) {
        // Be tolerant to key casing from backend
        final moodId = (e['MoodId'] ?? e['moodId']) as int;
        final mood   = (e['Mood'] ?? e['mood']) as String;
        final note   = (e['MoodNote'] ?? e['moodNote']) as String?;
        final raw    = (e['Date'] ?? e['date']) as String;

        // Accept "yyyy-MM-dd" or "yyyy/MM/dd"
        final norm = raw.replaceAll('/', '-');
        final dt   = DateTime.tryParse(norm) ?? DateTime.now();

        return EmployeeMood(
          employeeId: employeeId,
          moodId: moodId,
          mood: mood,
          note: note,
          date: dt,
        );
      }).toList();

      return Right(list);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      return Left(ServerFailure( msg));
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }
}
