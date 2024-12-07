import '../../../../data/data/leave_request_model.dart';

abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class LeaveRequestSuccess extends LeaveState {}

class LeaveRequestFailure extends LeaveState {
  final String errorMessage;

  LeaveRequestFailure({required this.errorMessage});
}

class LeaveLoaded extends LeaveState {
  final List<LeaveRequest> leaveRequests;

  LeaveLoaded({required this.leaveRequests});
}