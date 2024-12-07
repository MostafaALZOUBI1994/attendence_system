// models/leave_request.dart

class LeaveRequest {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;

  LeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  // Adding time properties to the constructor
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      leaveType: json['leaveType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    };
  }
}
