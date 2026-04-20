part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileFetch extends ProfileEvent {
  const ProfileFetch();
}

class ProfileUpdate extends ProfileEvent {
  final Map<String, dynamic> data;
  const ProfileUpdate(this.data);
  @override
  List<Object?> get props => [data];
}

class ProfileCreate extends ProfileEvent {
  final Map<String, dynamic> data;
  const ProfileCreate(this.data);
  @override
  List<Object?> get props => [data];
}
