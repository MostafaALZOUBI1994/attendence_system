import 'package:injectable/injectable.dart';
import '../repositories/mood_repository.dart';

@lazySingleton
class SubmitMoodUC {
  final MoodRepository repo;
  SubmitMoodUC(this.repo);

  MoodPostResult call(Params p) => repo.postMood(
    employeeId: p.employeeId,
    moodId: p.moodId,
    mood: p.mood,
    note: p.note,
    date: p.date,
  );
}

class Params {
  final int employeeId;
  final int moodId;
  final String mood;
  final String? note;
  final DateTime? date;
  Params({
    required this.employeeId,
    required this.moodId,
    required this.mood,
    this.note,
    this.date,
  });
}
