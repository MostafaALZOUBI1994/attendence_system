part of 'mood_bloc.dart';

@freezed
sealed class MoodState with _$MoodState {
  const factory MoodState.initial() = MoodInitial;
  const factory MoodState.submitting() = MoodSubmitting;
  const factory MoodState.submitted() =  MoodSubmitted;

  const factory MoodState.historyLoaded({
    required List<EmployeeMood> moods,
    EmployeeMood? lastMood,
    String? mostFrequent,
  }) = MoodHistoryLoaded;

  const factory MoodState.error(String message) = MoodError;
}
