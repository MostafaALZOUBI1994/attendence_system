abstract class LeaveEvent {}

class RequestLeave extends LeaveEvent {
  final String startDate;
  final String endDate;
  final String reason;
  final String leaveType;

  RequestLeave({
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
  });
}

class FetchLeaves extends LeaveEvent {}
