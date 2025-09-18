import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
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

        // Check if OTP is required from settings
        final apiService = ApiService();
        if (apiService.isOTPRequired()) {
          print("OTP required for login");
          emit(
            AuthError(
              'OTP verification required. Please enter the code sent to your email.',
            ),
          );
        } else {
          print("User received: ${user.toJson()}");
          emit(Authenticated(user));
        }
      } catch (e) {
        print("Login error: $e");
        emit(AuthError(e.toString()));
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

    on<ForgetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // TODO: Implement forget password API call
        // await authRepository.forgetPassword(event.email);
        emit(AuthError('Forget password feature coming soon!'));
      } catch (e) {
        emit(AuthError('Failed to send reset email'));
      }
    });

    on<VerifyOTPRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Simple OTP verification - in real app, this would call your API
        if (event.otp == '123456' || event.otp == '000000') {
          // For demo purposes, use a mock user after OTP verification
          final mockUser = User(
            id: 'otp_user',
            email: 'verified@lms.com',
            name: 'OTP Verified User',
            type: 'student',
            token: 'otp_token_${DateTime.now().millisecondsSinceEpoch}',
          );
          emit(Authenticated(mockUser));
        } else {
          emit(AuthError('Invalid OTP. Please try again.'));
        }
      } catch (e) {
        emit(AuthError('Failed to verify OTP: ${e.toString()}'));
      }
    });
  }
}
