import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/database_helper.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final DatabaseHelper _databaseHelper;

  LeaveBloc(this._databaseHelper) : super(LeaveInitial()) {
    // Handle RequestLeave event
    on<RequestLeave>((event, emit) async {
      try {
        // Simulate leave request processing
        await Future.delayed(Duration(seconds: 1));

        // Assuming leave request is saved in the database
        await _databaseHelper.insertLeaveRequest({
          'leaveType': event.leaveType,
          'startDate': event.startDate,
          'endDate': event.endDate,
          'reason': event.reason,
          'status': 'Pending',
        });

        emit(LeaveRequestSuccess());
      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });

    // Handle FetchLeaves event
    on<FetchLeaves>((event, emit) async {
      try {
        // Fetch leave data from the local database
        final leaveRequests = await _databaseHelper.getLeaveRequests();
        emit(LeaveLoaded(leaveRequests: leaveRequests));
      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });
  }
}
