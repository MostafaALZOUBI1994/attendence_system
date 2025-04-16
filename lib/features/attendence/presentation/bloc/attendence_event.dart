import 'package:freezed_annotation/freezed_annotation.dart';
part 'attendence_event.freezed.dart';

@freezed
class AttendenceEvent with _$AttendenceEvent {
  const factory AttendenceEvent.started() = Started;
  const factory AttendenceEvent.loadData() = LoadData;
  const factory AttendenceEvent.stepChanged(int newIndex) = StepChanged;
  const factory AttendenceEvent.checkIn(String mood) = CheckIn;
  const factory AttendenceEvent.tick() = Tick;
}

