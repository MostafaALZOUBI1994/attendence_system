import '../../domain/entities/employee.dart' as domain show Employee;
import '../models/employee_model.dart' show EmployeeModel;

extension EmployeeModelMapper on EmployeeModel {
  domain.Employee toEntity() {
    return domain.Employee(
        employeeUsername,
        departmentInEn,
        directManager,
        physicalOffice,
        employeeNameInAr,
        employeeTitleInAr,
        departmentInAr,
        employeeId,
        employeeNameInEn,
        empImage,
        email,
        empImage,
        mail,
        mobile,
        commonName,
        ipPhone,
        employeeTitleInEn,
        gracePeriod
    );
  }
}
