// models/leave_request.dart

class LeaveRequest {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String reason;

  LeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  // Adding time properties to the constructor
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      leaveType: json['leaveType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
    };
  }
}
