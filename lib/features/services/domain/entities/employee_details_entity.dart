import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_details_entity.freezed.dart';

@freezed
class EmployeeDetailsEntity with _$EmployeeDetailsEntity {
  const factory EmployeeDetailsEntity({
    required String displayNameAr,
    required String displayNameEn,
    required String titleEn,
    required String titleAr,
    required String phoneNumber,
    required String email,
    /// Raw base64 (can come from `Photo` or `PhotoBytes`)
    String? photoBase64,
  }) = _EmployeeDetailsEntity;
}
