part of 'attendence_bloc.dart';

@freezed
class AttendenceEvent with _$AttendenceEvent {
  const factory AttendenceEvent.started() = Started;

  /// Fetch TodayStatus from API (on first load & app resume)
  const factory AttendenceEvent.loadData() = LoadData;

  /// Optional: step tweak from UI, if you keep it
  const factory AttendenceEvent.stepChanged(int newIndex) = StepChanged;

  /// Offsite check-in (first mood + any later offsite taps)
  const factory AttendenceEvent.checkIn(String mood) = CheckIn;

  /// 1s ticker for remaining time / progress
  const factory AttendenceEvent.tick() = Tick;

  /// Refresh only offSiteCheckIns from SharedPreferences (no API call)
  const factory AttendenceEvent.refreshOffsites() = RefreshOffsites;
}