import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      print("print: ${event.email}");
      emit(AuthLoading());

      try {
        final user = await authRepository.login(event.email, event.password);

        // Optional delay after receiving the response
        // await Future.delayed(Duration(seconds: 4));

        print("User received: ${user.toJson()}");
        emit(Authenticated(user));
      } catch (e) {
        print("Login error: $e");
        emit(AuthError('Login failed'));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.email, event.password);
        final user = await authRepository.login(event.email, event.password);
        print("print:$user");
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError('Registration failed'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(Unauthenticated());
    });
  }
}
