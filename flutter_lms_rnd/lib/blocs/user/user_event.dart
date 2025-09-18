import 'package:equatable/equatable.dart';
import 'package:flutter_lms_rnd/models/user_model.dart';


abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {}

class CreateUser extends UserEvent {
  final User user;

  CreateUser(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUser extends UserEvent {
  final User user;

  UpdateUser(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUser extends UserEvent {
  final String id;

  DeleteUser(this.id);

  @override
  List<Object> get props => [id];
}