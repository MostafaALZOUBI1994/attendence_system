import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
part 'report_model.g.dart';

@JsonSerializable()
class Report {
  @JsonKey(name: 'EmployeeID')
  final String employeeId;

  @JsonKey(name: 'pdate', fromJson: _parseDate)
  final DateTime pdate;

  @JsonKey(name: 'Check_In')
  final String checkIn;

  @JsonKey(name: 'Check_Out')
  final String checkOut;

  @JsonKey(name: 'status')
  final String status;


  Report({
    required this.employeeId,
    required this.pdate,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  static DateTime _parseDate(String dateStr) {
    return DateFormat('dd/MM/yyyy', 'en').parse(dateStr);
  }
}