import 'package:equatable/equatable.dart';


abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}
class LoadAttendance extends AttendanceEvent {}

class MarkAttendance extends AttendanceEvent {
  final String date;
  final String status;

  const MarkAttendance({required this.date, required this.status});

  @override
  List<Object?> get props => [date, status];
}