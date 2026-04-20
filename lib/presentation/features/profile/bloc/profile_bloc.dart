import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/domain/usecases/profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUseCase _profileUseCase;

  ProfileBloc({required ProfileUseCase profileUseCase})
      : _profileUseCase = profileUseCase,
        super(const ProfileState()) {
    on<ProfileFetch>(_onFetch);
    on<ProfileCreate>(_onCreate);
    on<ProfileUpdate>(_onUpdate);
  }

  Future<void> _onFetch(ProfileFetch event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileUseCase.getProfile();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(ProfileCreate event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileUseCase.createProfile(event.data);
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(ProfileUpdate event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileUseCase.updateProfile(event.data);
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: e.toString()));
    }
  }
}
