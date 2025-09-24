import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_mood.dart';

typedef MoodPostResult = Future<Either<Failure, Unit>>;
typedef MoodHistoryResult = Future<Either<Failure, List<EmployeeMood>>>;

abstract class MoodRepository {
  MoodPostResult postMood({
    required int moodId,
    required String mood,
    String? note,
    DateTime? date,
  });

  MoodHistoryResult getMoodHistory({
    required DateTime from,
    required DateTime to,
  });
}
