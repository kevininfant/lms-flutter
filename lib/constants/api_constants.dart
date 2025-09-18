class ApiConstants {
  // Base URL of your backend (Node.js + MongoDB)
  static const String baseUrl = 'https://taskmanagement-api-1.onrender.com/api/v1'; // Change for production

  // Auth endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';

  // To-Do endpoints (example)
  static const String todos = '$baseUrl/todos';
  static String todoById(String id) => '$baseUrl/todos/$id';
}