import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';

class ApiService {
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _settings = {};
  String? _token;
  bool _isInitialized = false;

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/auth_data.json',
      );
      final data = json.decode(response);
      _users = List<Map<String, dynamic>>.from(data['users']);
      _settings = data['settings'];
      _isInitialized = true;
    } catch (e) {
      print('Error loading auth data: $e');
      _users = [];
      _settings = {};
    }
  }

  void setToken(String token) {
    _token = token;
  }

  Future<User> login(String email, String password) async {
    await _initializeData();

    // Find user by email and password
    final user = _users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    // Generate a mock token
    final token =
        'mock_token_${user['_id']}_${DateTime.now().millisecondsSinceEpoch}';
    _token = token;

    // Add token to user data
    final userWithToken = Map<String, dynamic>.from(user);
    userWithToken['token'] = token;

    print('Login successful for: ${user['email']}');
    return User.fromJson(userWithToken);
  }

  Future<void> register(String email, String password) async {
    await _initializeData();

    // Check if user already exists
    final existingUser = _users.any((user) => user['email'] == email);
    if (existingUser) {
      throw Exception('User already exists with this email');
    }

    // Create new user
    final newUser = {
      '_id': (_users.length + 1).toString(),
      'email': email,
      'password': password,
      'name': email.split('@')[0], // Use email prefix as name
      'type': 'student', // Default type
      'age': null,
      'gender': null,
      'mobile': null,
      'address': null,
      'dob': null,
      'imagecode': null,
    };

    _users.add(newUser);
    print('Registration successful for: $email');
  }

  Future<User> insertUser(
    String name,
    String email,
    int age,
    String gender,
    String dob,
    String mobile,
    String address,
  ) async {
    await _initializeData();

    if (_token == null) {
      throw Exception('Token not found. User not authenticated.');
    }

    // Find current user by token
    final currentUser = _users.firstWhere(
      (user) => user['token'] == _token,
      orElse: () => throw Exception('User not found'),
    );

    // Update user data
    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['name'] = name;
    updatedUser['age'] = age;
    updatedUser['gender'] = gender;
    updatedUser['dob'] = dob;
    updatedUser['mobile'] = mobile;
    updatedUser['address'] = address;

    // Update in the users list
    final userIndex = _users.indexWhere(
      (user) => user['_id'] == currentUser['_id'],
    );
    if (userIndex != -1) {
      _users[userIndex] = updatedUser;
    }

    print('User updated successfully: $name');
    return User.fromJson(updatedUser);
  }

  // Fetch a list of users
  Future<List<User>> fetchUsers() async {
    await _initializeData();
    return _users.map((userData) => User.fromJson(userData)).toList();
  }

  // Create a new user
  Future<User> createUser(User user) async {
    await _initializeData();

    // Check if user already exists
    final existingUser = _users.any((u) => u['email'] == user.email);
    if (existingUser) {
      throw Exception('User already exists with this email');
    }

    // Add new user
    final newUser = user.toJson();
    newUser['_id'] = (_users.length + 1).toString();
    _users.add(newUser);

    print('User created successfully: ${user.email}');
    return User.fromJson(newUser);
  }

  // Update an existing user
  Future<void> updateUser(User user) async {
    await _initializeData();

    final userIndex = _users.indexWhere((u) => u['_id'] == user.id);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    _users[userIndex] = user.toJson();
    print('User updated successfully: ${user.email}');
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    await _initializeData();

    final userIndex = _users.indexWhere((u) => u['_id'] == id);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    _users.removeAt(userIndex);
    print('User deleted successfully: $id');
  }

  // Get settings
  Map<String, dynamic> getSettings() {
    return _settings;
  }

  // Check if OTP is required (from settings)
  bool isOTPRequired() {
    return _settings['requireOTP'] ?? false;
  }
}
