import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel {
  @JsonKey(name: 'EmployeeName', defaultValue: '')
  final String employeeNameInEn;

  @JsonKey(name: 'EmployeeId', defaultValue: '')
  final String employeeId;

  @JsonKey(name: 'EmployeeUsername', defaultValue: '')
  final String employeeUsername;

  @JsonKey(name: 'Department', defaultValue: '')
  final String departmentInEn;

  @JsonKey(name: 'UserImage', defaultValue: '')
  final String userImage;

  @JsonKey(name: 'Email', defaultValue: '')
  final String email;

  @JsonKey(
    name: 'Manager',
    defaultValue: '',
  )
  final String directManager;

  @JsonKey(name: 'EmpImage', defaultValue: '')
  final String empImage;

  @JsonKey(name: 'Mail', defaultValue: '')
  final String mail;

  @JsonKey(name: 'Physicaldeliveryofficename', defaultValue: '')
  final String physicalOffice;

  @JsonKey(name: 'Mobile', defaultValue: '')
  final String mobile;

  @JsonKey(name: 'Extensionattribute1', defaultValue: '')
  final String employeeNameInAr;

  @JsonKey(name: 'Extensionattribute2', defaultValue: '')
  final String employeeTitleInAr;

  @JsonKey(name: 'Extensionattribute3', defaultValue: '')
  final String departmentInAr;

  @JsonKey(name: 'GracePeriod', defaultValue: '')
  final String gracePeriod;

  @JsonKey(name: 'Title', defaultValue: '')
  final String employeeTitleInEn;

  @JsonKey(name: 'CN')
  final String? commonName;

  @JsonKey(name: 'ipphone', defaultValue: '')
  final String ipPhone;

  EmployeeModel(
      this.employeeNameInEn,
      this.departmentInEn,
      this.physicalOffice,
      this.employeeNameInAr,
      this.employeeTitleInAr,
      this.departmentInAr,
      this.employeeId,
      this.employeeUsername,
      this.userImage,
      this.email,
      this.empImage,
      this.mail,
      this.mobile,
      this.commonName,
      this.ipPhone,
      this.directManager,
      this.gracePeriod,
      this.employeeTitleInEn);

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);

  String get profileImage => userImage.isNotEmpty
      ? userImage
      : empImage.isNotEmpty
          ? empImage
          : '';
}
