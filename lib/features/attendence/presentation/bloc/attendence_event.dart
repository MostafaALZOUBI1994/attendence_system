part of 'attendence_bloc.dart';

@freezed
class AttendenceEvent with _$AttendenceEvent {
  const factory AttendenceEvent.started() = Started;
  const factory AttendenceEvent.loadData() = LoadData;
  const factory AttendenceEvent.stepChanged(int newIndex) = StepChanged;
  const factory AttendenceEvent.checkIn(String mood) = CheckIn;
  const factory AttendenceEvent.tick() = Tick;
}

