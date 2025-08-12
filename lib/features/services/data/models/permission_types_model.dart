class PermissionTypesModel {
  final String permissionCode;
  final String permissionNameEN;
  final String permissionNameAR;

  PermissionTypesModel({
    required this.permissionCode,
    required this.permissionNameEN,
    required this.permissionNameAR,
  });

  factory PermissionTypesModel.fromJson(Map<String, dynamic> json) {
    return PermissionTypesModel(
      permissionCode: json['Permission_code'],
      permissionNameEN: json['Permission_NameEN'],
      permissionNameAR: json['Permission_NameAR'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Permission_code': permissionCode,
      'Permission_NameEN': permissionNameEN,
      'Permission_NameAR': permissionNameAR,
    };
  }
}