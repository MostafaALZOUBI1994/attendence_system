import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/local_services/local_services.dart';
import '../models/employee_model.dart';

abstract class EmployeeLocalDataSource {
  Future<void> cacheEmployee(EmployeeModel model);

  Future<EmployeeModel?> getProfile();

  Future<String?> getEmployeeId();
}

@LazySingleton(as: EmployeeLocalDataSource)
class EmployeeLocalDataSourceImpl implements EmployeeLocalDataSource {
  final LocalService _localService;

  EmployeeLocalDataSourceImpl(this._localService);

  @override
  Future<void> cacheEmployee(EmployeeModel model) async {
    final jsonString = jsonEncode(model.toJson());
    await _localService.save(cachedEmployeeKey, jsonString);
  }

  @override
  Future<EmployeeModel?> getProfile() async {
    final jsonString = _localService.get(cachedEmployeeKey);
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return EmployeeModel.fromJson(jsonMap);
  }

  @override
  Future<String?> getEmployeeId() async {
    final profile = await getProfile();
    return profile?.employeeId;
  }
}
