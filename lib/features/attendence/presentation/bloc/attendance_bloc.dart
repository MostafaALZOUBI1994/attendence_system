import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Attendance Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class MarkAttendance extends AttendanceEvent {
  final String date;
  final String status;

  const MarkAttendance({required this.date, required this.status});

  @override
  List<Object?> get props => [date, status];
}

// Attendance States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceMarked extends AttendanceState {
  final String date;
  final String status;

  const AttendanceMarked({required this.date, required this.status});

  @override
  List<Object?> get props => [date, status];
}

// Attendance Bloc
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceInitial()) {
    on<MarkAttendance>((event, emit) {
      emit(AttendanceMarked(date: event.date, status: event.status));
    });
  }
}
