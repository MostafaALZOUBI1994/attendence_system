import 'package:attendence_system/data/repositories/database_helper.dart';
import 'package:attendence_system/features/leave/presentation/bloc/leave_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'leave_event.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final DatabaseHelper _databaseHelper;

  LeaveBloc(this._databaseHelper) : super(LeaveInitial()) {
    // Handle RequestLeave event
    on<RequestLeave>((event, emit) async {
      try {
        // Fetch leave data from the local database
        final leaveRequests = await _databaseHelper.getLeaveRequests();

        // Check for overlapping leave requests
        bool isOverlapping = false;
        for (var leaveRequest in leaveRequests) {
          DateTime existingStartDate = DateTime.parse(leaveRequest.startDate);
          DateTime existingEndDate = DateTime.parse(leaveRequest.endDate);
          DateTime newStartDate = DateTime.parse(event.startDate);
          DateTime newEndDate = DateTime.parse(event.endDate);

          if (newStartDate.isBefore(existingEndDate) && newEndDate.isAfter(existingStartDate)) {
            isOverlapping = true;
            break;
          }
        }

        if (isOverlapping) {
          emit(LeaveRequestFailure(errorMessage: 'Leave dates overlap with an existing request.'));
          return;
        }

        // If no overlap, process the leave request
        await _databaseHelper.insertLeaveRequest({
          'leaveType': event.leaveType,
          'startDate': event.startDate,
          'endDate': event.endDate,
          'reason': event.reason,
          'status': 'Pending',
        });

        // Fetch updated leave requests
        final updatedLeaveRequests = await _databaseHelper.getLeaveRequests();
        emit(LeaveLoaded(leaveRequests: updatedLeaveRequests));

      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });

    // Handle FetchLeaves event
    on<FetchLeaves>((event, emit) async {
      try {
        final leaveRequests = await _databaseHelper.getLeaveRequests();
        emit(LeaveLoaded(leaveRequests: leaveRequests));
      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });
  }
}
