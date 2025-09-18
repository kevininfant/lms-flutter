import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    // Handling FetchUsers event
    on<FetchUsers>((event, emit) async {
      emit(UserLoading()); // Emit loading state
      try {
        final users = await userRepository.getUsers(); // Fetch users
        emit(UserLoaded(users)); // Emit loaded state with users
      } catch (e) {
        emit(UserError(e.toString())); // Emit error state on failure
      }
    });

    // Handling CreateUser event
    on<CreateUser>((event, emit) async {
      emit(UserLoading()); // Emit loading state
      try {
        final user = await userRepository.createUser(event.user); // Create user
        emit(UserLoaded([user])); // Emit loaded state with the created user
      } catch (e) {
        emit(UserError(e.toString())); // Emit error state on failure
      }
    });

    // Handling UpdateUser event
    on<UpdateUser>((event, emit) async {
      emit(UserLoading()); // Emit loading state
      try {
        await userRepository.updateUser(event.user); // Update user
        emit(UserUpdated(event.user)); // Emit updated state
      } catch (e) {
        emit(UserError(e.toString())); // Emit error state on failure
      }
    });

    // Handling DeleteUser event
    on<DeleteUser>((event, emit) async {
      emit(UserLoading()); // Emit loading state
      try {
        await userRepository.deleteUser(event.id); // Delete user
        emit(UserDeleted(event.id)); // Emit deleted state
      } catch (e) {
        emit(UserError(e.toString())); // Emit error state on failure
      }
    });
  }
}