import 'package:injectable/injectable.dart';
import '../repositories/mood_repository.dart';

@lazySingleton
class FetchMoodHistoryUC {
  final MoodRepository repo;
  FetchMoodHistoryUC(this.repo);

  MoodHistoryResult call(Params p) => repo.getMoodHistory(
    from: p.from,
    to: p.to,
  );
}

class Params {
  final DateTime from;
  final DateTime to;
  Params({required this.from, required this.to});
}
