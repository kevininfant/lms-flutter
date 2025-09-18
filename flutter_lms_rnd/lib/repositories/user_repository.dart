import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class UserRepository {
  final ApiService apiService;
  final TokenService tokenService;

  UserRepository(this.apiService, {required this.tokenService});

  Future<List<User>> getUsers() async {
    return await apiService.fetchUsers();
  }

  Future<User> createUser(User user) async {
    final createdUser = await apiService.createUser(user);
    await tokenService.saveToken(createdUser.token!); // Save token after creating user
    return createdUser;
  }

  Future<void> updateUser(User user) async {
    await apiService.updateUser(user);
  }

  Future<void> deleteUser(String id) async {
    await apiService.deleteUser(id);
  }

  Future<String?> getToken() async {
    return await tokenService.getToken();
  }

  Future<void> deleteToken() async {
    await tokenService.deleteToken();
  }
}