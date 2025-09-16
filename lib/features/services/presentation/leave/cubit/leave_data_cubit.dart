// features/services/leave/cubit/leave_data_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/eleave_entity.dart';
import '../../../domain/entities/permission_types_entity.dart';
import '../../../domain/usecases/get_allowed_hours.dart';
import '../../../domain/usecases/get_permission_types.dart';

part 'leave_data_cubit.freezed.dart';
part 'leave_data_state.dart';

class LeaveDataCubit extends Cubit<LeaveDataState> {
  final GetPermissionTypesUseCase _perm;
  final GetAllowedHourseUseCase _allowed;
  LeaveDataCubit(this._perm, this._allowed) : super(const LeaveDataState.initial());

  Future<void> load() async {
    emit(const LeaveDataState.loading());
    final types = await _perm.execute();
    final hours = await _allowed.execute();
    types.fold(
          (f) => emit(LeaveDataState.error(f.message)),
          (tList) => hours.fold(
            (f) => emit(LeaveDataState.error(f.message)),
            (bal) => emit(LeaveDataState.loaded(leaveTypes: tList, leaveBalance: bal)),
      ),
    );
  }
}
