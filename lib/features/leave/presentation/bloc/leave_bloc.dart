import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/data/leave_request_model.dart';
import '../../../../data/repositories/database_helper.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final DatabaseHelper _databaseHelper;
  List<LeaveRequest> _currentLeaves = [];

  LeaveBloc(this._databaseHelper) : super(LeaveInitial()) {
    on<RequestLeave>((event, emit) async {
      try {
        // Fetch leave data from the local database
        final leaveRequests = await _databaseHelper.getLeaveRequests();
        _currentLeaves = leaveRequests;

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
          emit(LeaveRequestFailure(
            errorMessage: 'Leave dates overlap with an existing request.',
            currentLeaves: _currentLeaves,
          ));
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
        _currentLeaves = updatedLeaveRequests;
        emit(LeaveLoaded(leaveRequests: updatedLeaveRequests));

      } catch (error) {
        emit(LeaveRequestFailure(
          errorMessage: error.toString(),
          currentLeaves: _currentLeaves,
        ));
      }
    });

    on<FetchLeaves>((event, emit) async {
      try {
        final leaveRequests = await _databaseHelper.getLeaveRequests();
        _currentLeaves = leaveRequests;
        emit(LeaveLoaded(leaveRequests: _currentLeaves));
      } catch (error) {
        emit(LeaveRequestFailure(
          errorMessage: error.toString(),
          currentLeaves: _currentLeaves,
        ));
      }
    });
  }
}