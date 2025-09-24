import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/employee_mood.dart';
import '../../domain/usecases/fetch_mood_history.dart' as uc_fetch;
import '../../domain/usecases/submit_mood.dart' as uc_submit;

part 'mood_bloc.freezed.dart';
part 'mood_event.dart';
part 'mood_state.dart';

@injectable
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final uc_submit.SubmitMoodUC submitMoodUC;
  final uc_fetch.FetchMoodHistoryUC fetchMoodHistoryUC;

  MoodBloc(this.submitMoodUC, this.fetchMoodHistoryUC)
      : super(const MoodState.initial()) {
    on<SubmitMood>(_onSubmitMood);
    on<FetchMoodHistory>(_onFetchHistory);
  }

  Future<void> _onSubmitMood(SubmitMood e, Emitter<MoodState> emit) async {
    emit(const MoodState.submitting());
    final res = await submitMoodUC(uc_submit.Params(
      moodId: e.moodId,
      mood: e.mood,
      note: e.note,
      date: e.date,
    ));
    res.fold(
          (f) => emit(MoodState.error(f.message)),
          (_) => emit(const MoodState.submitted()),
    );
  }

  Future<void> _onFetchHistory(FetchMoodHistory e, Emitter<MoodState> emit) async {
    final now  = DateTime.now();
    final from = e.from ?? now.subtract(const Duration(days: 2));
    final to   = e.to   ?? now;

    final res = await fetchMoodHistoryUC(uc_fetch.Params(
      from: DateTime(from.year, from.month, from.day),
      to:   DateTime(to.year, to.month, to.day),
    ));

    res.fold(
          (f) => emit(MoodState.error(f.message)),
          (list) {
            final last = list.isNotEmpty ? list.last : null;
        final freq = _mostFrequentMood(list);
        emit(MoodState.historyLoaded(moods: list, lastMood: last, mostFrequent: freq));
      },
    );
  }

  String? _mostFrequentMood(List<EmployeeMood> list) {
    if (list.isEmpty) return null;
    final counts = <String, int>{};
    for (final m in list) {
      final key = m.mood.trim();
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
