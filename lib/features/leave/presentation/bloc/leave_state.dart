import '../../../../data/data/leave_request_model.dart';

abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class LeaveRequestSuccess extends LeaveState {}

class LeaveRequestFailure extends LeaveState {
  final String errorMessage;
  final List<LeaveRequest> currentLeaves;

  LeaveRequestFailure({
    required this.errorMessage,
    required this.currentLeaves,
  });
}

class LeaveLoaded extends LeaveState {
  final List<LeaveRequest> leaveRequests;

  LeaveLoaded({required this.leaveRequests});
}