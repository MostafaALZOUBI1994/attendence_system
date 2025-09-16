part of 'employees_cubit.dart';

@freezed
class EmployeesState with _$EmployeesState {
  const factory EmployeesState.initial() = _Initial;
  const factory EmployeesState.loading() = _Loading;
  const factory EmployeesState.loaded(List<EmployeeDetailsEntity> list) = _Loaded;
  const factory EmployeesState.error(String message) = _Error;
}
