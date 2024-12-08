import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/database_helper.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<MarkAttendance>(_onMarkAttendance);
  }

  Future<void> _onLoadAttendance(
      LoadAttendance event, Emitter<AttendanceState> emit) async {
    final records = await DatabaseHelper.instance.getAttendance();
    emit(AttendanceLoaded(records: records));
  }

  Future<void> _onMarkAttendance(
      MarkAttendance event, Emitter<AttendanceState> emit) async {
    // Insert into the database
    await DatabaseHelper.instance.insertAttendance({
      'date': event.date,
      'status': event.status,
    });

    // Reload updated records
    final updatedRecords = await DatabaseHelper.instance.getAttendance();
    emit(AttendanceLoaded(records: updatedRecords));
  }
}

