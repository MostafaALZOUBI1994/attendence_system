import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

// Initial state before anything is loaded
class AttendanceInitial extends AttendanceState {}

// State when attendance records are loaded successfully

// State for error scenarios
class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AttendanceLoaded extends AttendanceState {
  final List<Map<String, dynamic>> records;

  const AttendanceLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}