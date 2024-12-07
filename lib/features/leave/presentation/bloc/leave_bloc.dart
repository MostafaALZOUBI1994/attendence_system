import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/data/leave_request_model.dart';
import 'leave_event.dart';
import 'leave_state.dart';


class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(LeaveInitial()) {
    // Handle RequestLeave event
    on<RequestLeave>((event, emit) async {
      try {
        // Simulate leave request processing
        await Future.delayed(Duration(seconds: 1));
        // Assuming leave request is successful
        emit(LeaveRequestSuccess());
      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });

    // Handle FetchLeaves event
    on<FetchLeaves>((event, emit) async {
      try {
        // Simulate fetching leave data
        await Future.delayed(Duration(seconds: 1));
        final leaveRequests = [
          LeaveRequest(
            leaveType: 'Sick',
            startDate: '2024-12-01',
            endDate: '2024-12-05',

            reason: 'Flu',
            startTime: '10:45',
            endTime: '10:45',
          ),
          LeaveRequest(
            leaveType: 'Vacation',
            startDate: '2024-12-10',
            endDate: '2024-12-15',
            reason: 'Family time',
            startTime: '10:45',
            endTime: '10:45',
          ),
        ];
        emit(LeaveLoaded(leaveRequests: leaveRequests));
      } catch (error) {
        emit(LeaveRequestFailure(errorMessage: error.toString()));
      }
    });
  }
}
