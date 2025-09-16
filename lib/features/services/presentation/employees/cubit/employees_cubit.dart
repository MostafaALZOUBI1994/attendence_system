// features/services/employees/cubit/employees_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/injection.dart';
import '../../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../../domain/entities/employee_details_entity.dart';
import '../../../domain/usecases/get_employee_details.dart';


part 'employees_cubit.freezed.dart';
part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final GetEmployeeDetailsUseCase _getEmployeeDetails;
  EmployeesCubit(this._getEmployeeDetails) : super(const EmployeesState.initial());

  Future<void> loadForMyDepartment() async {
    emit(const EmployeesState.loading());
    try {
      final profile = await getIt<EmployeeLocalDataSource>().getProfile();
      final dept = profile?.departmentInEn ?? "";
      final res = await _getEmployeeDetails.execute(dept);
      res.fold(
            (f) => emit(EmployeesState.error(f.message)),
            (list) => emit(EmployeesState.loaded(list)),
      );
    } catch (e) {
      emit(EmployeesState.error(e.toString()));
    }
  }
}
