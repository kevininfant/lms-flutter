import 'package:equatable/equatable.dart';
import 'package:flutter_lms_rnd/models/user_model.dart';

abstract class UserState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;

  UserLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserUpdated extends UserState {
  final User user;

  UserUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class UserDeleted extends UserState {
  final String id;

  UserDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object> get props => [message];
}