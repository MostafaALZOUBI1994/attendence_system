class EmployeeDetailsModel {
  final String displayNameAr;
  final String displayNameEn;
  final String titleEn;
  final String titleAr;
  final String phoneNumber;
  final String? photoBytes; // may be null
  final String? photo;      // may contain the base64
  final String email;

  EmployeeDetailsModel({
    required this.displayNameAr,
    required this.displayNameEn,
    required this.titleEn,
    required this.titleAr,
    required this.phoneNumber,
    this.photoBytes,
    this.photo,
    required this.email
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsModel(
      displayNameAr: (json['DisplayNameAr'] as String?)?.trim() ?? '',
      displayNameEn: (json['DisplayNameEn'] as String?)?.trim() ?? '',
      titleEn: (json['TitleEn'] as String?)?.trim() ?? '',
      titleAr: (json['TitleAr'] as String?)?.trim() ?? '',
      phoneNumber: (json['PhoneNumber'] as String?)?.trim() ?? '',
      photoBytes: json['PhotoBytes'] as String?,
      photo: json['Photo'] as String?,
      email: (json['Email'] as String?)?.trim() ?? '',
    );
  }


  /// Prefer `Photo`, then `PhotoBytes`
  String? get photoBase64 =>
      (photo != null && photo!.isNotEmpty) ? photo
          : (photoBytes != null && photoBytes!.isNotEmpty) ? photoBytes
          : null;
}
