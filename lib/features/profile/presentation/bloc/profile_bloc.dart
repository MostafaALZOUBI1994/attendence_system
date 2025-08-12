import 'package:moet_hub/features/profile/presentation/bloc/profile_event.dart';
import 'package:moet_hub/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/fetch_health_data.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchHealthData fetchHealthData;

  ProfileBloc({required this.fetchHealthData}) : super(const ProfileState.initial()) {
    on<FetchProfileDataEvent>((event, emit) async {
      try {
        final result = await fetchHealthData();
        result.fold(
              (failure) => emit(ProfileState.error(failure.message)),
              (healthData) => emit(ProfileState.loaded(healthData: healthData)),
        );
      } catch (e) {
        emit(ProfileState.error(e.toString()));
      }
    });
  }
}
