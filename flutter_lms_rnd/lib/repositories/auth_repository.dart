import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService api;

  AuthRepository(this.api);

  Future<User> login(String email, String password) =>
      api.login(email, password);

  Future<void> register(String email, String password) =>
      api.register(email, password);
}