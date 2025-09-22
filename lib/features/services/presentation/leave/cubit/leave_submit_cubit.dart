import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/leave_request_params.dart';
import '../../../domain/usecases/submit_leaveRequest.dart';

part 'leave_submit_cubit.freezed.dart';
part 'leave_submit_state.dart';

@injectable
class LeaveSubmitCubit extends Cubit<LeaveSubmitState> {
  final SubmitLeaveRequestUseCase _submit;
  LeaveSubmitCubit(this._submit) : super(const LeaveSubmitState.idle());

  Future<void> submit(SubmitLeaveRequestParams p) async {
    emit(const LeaveSubmitState.submitting());
    final res = await _submit.execute(p);
    res.fold(
          (f) => emit(LeaveSubmitState.failure(f.message)),
          (msg) => emit(LeaveSubmitState.success(msg)),
    );
  }
}

