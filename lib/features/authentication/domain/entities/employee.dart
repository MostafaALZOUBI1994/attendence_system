class Employee {
  final String id;
  final String employeeNameInEn;
  final String employeeUsername;
  final String departmentInEn;
  final String userImageUrl;
  final String email;
  final String directManager;
  final String empImageUrl;
  final String mail;
  final String physicalOffice;
  final String mobile;
  final String employeeNameInAr;
  final String employeeTitleInAr;
  final String employeeTitleInEn;
  final String gracePeriod;
  final String departmentInAr;
  final String? commonName;
  final String ipPhone;

  const Employee(
      this.employeeUsername,
      this.departmentInEn,
      this.directManager,
      this.physicalOffice,
      this.employeeNameInAr,
      this.employeeTitleInAr,
      this.departmentInAr,
      this.id,
      this.employeeNameInEn,
      this.userImageUrl,
      this.email,
      this.empImageUrl,
      this.mail,
      this.mobile,
      this.commonName,
      this.ipPhone,
      this.employeeTitleInEn,
      this.gracePeriod);
}
