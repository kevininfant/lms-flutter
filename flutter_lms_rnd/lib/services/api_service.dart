import 'dart:convert';
import 'package:flutter_lms_rnd/constants/api_constants.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ApiService {
  final String baseUrl = 'https://yourapi.com/api/users'; // Replace with your actual API URL
    final client = http.Client();
  String? _token;

   void setToken(String token) {
    _token = token;
  }

   Future<User> login(String email, String password) async {
    print("api:${ApiConstants.baseUrl}");
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('status: ${response.statusCode}');
    print('body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];

      // Extract token
      final token = data['token'];
      _token = token;

      // Extract user map
      final userJson = data['user'];

      // Add token into userJson because your User model expects token inside
      userJson['token'] = token;

      // Now parse
      return User.fromJson(userJson);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> register(String email, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Registration failed');
    }
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
    print("token123: $_token");
    if (_token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/insertuser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        'dob': dob,
        'mobile': mobile,
        'address': address,
      }),
    );
    print('status: ${response.statusCode}');
    print('body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(
        data,
      ); // Assuming you have a fromJson() in User model
    } else {
      throw Exception('Failed to insert user: ${response.statusCode}');
    }
  }


  // Fetch a list of users
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  // Create a new user
  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }

  // Update an existing user
  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${user.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }
}