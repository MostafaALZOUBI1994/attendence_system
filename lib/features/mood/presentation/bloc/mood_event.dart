part of 'mood_bloc.dart';

@freezed
sealed class MoodEvent with _$MoodEvent {
  const factory MoodEvent.submitMood({

    required int moodId,
    required String mood,
    String? note,
    DateTime? date, // repo can default to now
  }) = SubmitMood;

  const factory MoodEvent.fetchMoodHistory({
    DateTime? from, // if null -> last 5 days (handled in bloc)
    DateTime? to,   // if null -> now
  }) = FetchMoodHistory;
}
