import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/health_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.loaded({required HealthData healthData}) = ProfileLoaded;
  const factory ProfileState.error(String message) = ProfileError;
}
