class SubmitLeaveRequestParams {
  final String datedaytype;
  final String fromtime;
  final String totime;
  final String duration;
  final String reason;
  final String attachment;
  final String eleavetype;

  SubmitLeaveRequestParams({
    required this.datedaytype,
    required this.fromtime,
    required this.totime,
    required this.duration,
    required this.reason,
    required this.attachment,
    required this.eleavetype,
  });
}