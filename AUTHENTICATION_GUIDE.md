# Authentication Flow Implementation Guide

This document explains the complete authentication flow implementation using the BLoC pattern in the Flutter LMS Product application.

## Architecture Overview

The authentication system follows the BLoC (Business Logic Component) pattern with the following structure:

```
lib/
├── blocs/auth/
│   ├── auth_bloc.dart      # Main BLoC class handling auth logic
│   ├── auth_event.dart     # Events (LoginRequested, RegisterRequested, etc.)
│   └── auth_state.dart     # States (AuthInitial, AuthLoading, Authenticated, etc.)
├── repositories/
│   └── auth_repository.dart # Repository pattern for API calls
├── services/
│   └── api_service.dart    # HTTP service for API communication
├── models/
│   └── user.dart          # User model
├── screens/
│   ├── login_screen.dart   # Login/Register UI
│   ├── dashboard_screen.dart # Post-authentication dashboard
│   └── splash_screen.dart  # Loading screen
└── widgets/
    └── auth_form.dart      # Reusable authentication form widget
```

## Key Components

### 1. AuthBloc (`lib/blocs/auth/auth_bloc.dart`)

The main BLoC that handles all authentication-related business logic:

- **LoginRequested**: Handles user login
- **RegisterRequested**: Handles user registration
- **LogoutRequested**: Handles user logout
- **ForgetPasswordRequested**: Handles password reset requests
- **VerifyOTPRequested**: Handles OTP verification

### 2. AuthEvent (`lib/blocs/auth/auth_event.dart`)

Events that trigger state changes:

```dart
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}
```

### 3. AuthState (`lib/blocs/auth/auth_state.dart`)

States representing the authentication status:

- `AuthInitial`: Initial state
- `AuthLoading`: Loading state during API calls
- `Authenticated`: User is logged in (contains User object)
- `AuthError`: Error state with error message
- `Unauthenticated`: User is logged out

### 4. User Model (`lib/models/user.dart`)

Represents user data with JSON serialization support.

### 5. AuthRepository (`lib/repositories/auth_repository.dart`)

Repository pattern implementation that abstracts API calls:

```dart
Future<User> login(String email, String password) =>
    api.login(email, password);
```

### 6. ApiService (`lib/services/api_service.dart`)

HTTP service handling actual API communication with the backend.

## Authentication Flow

### Login Process

1. User enters email and password in `AuthForm`
2. `LoginRequested` event is dispatched to `AuthBloc`
3. `AuthBloc` emits `AuthLoading` state
4. `AuthRepository` calls `ApiService.login()`
5. On success: `Authenticated` state with User object
6. On error: `AuthError` state with error message
7. UI updates based on state changes

### State Management

The app uses `BlocBuilder` and `BlocListener` to react to state changes:

- **BlocBuilder**: Rebuilds UI based on state changes
- **BlocListener**: Performs side effects (navigation, snackbars)

### Navigation Flow

```dart
// In main.dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is Authenticated) {
      return DashboardScreen(user: state.user);
    } else {
      return LoginScreen();
    }
  },
)
```

## Features Implemented

### ✅ Core Authentication
- [x] User Login
- [x] User Registration
- [x] User Logout
- [x] Loading States
- [x] Error Handling

### ✅ UI Components
- [x] Login/Register Forms
- [x] Dashboard Screen
- [x] Loading Indicators
- [x] Error Messages
- [x] Form Validation

### ✅ State Management
- [x] BLoC Pattern Implementation
- [x] Repository Pattern
- [x] Service Layer
- [x] Model Classes

### 🚧 Future Enhancements
- [ ] Password Reset Implementation
- [ ] OTP Verification
- [ ] Remember Me Functionality
- [ ] Social Login Integration
- [ ] Biometric Authentication

## API Integration

The app connects to a backend API with the following endpoints:

- `POST /api/v1/login` - User login
- `POST /api/v1/register` - User registration
- `POST /api/v1/insertuser` - Update user profile (requires authentication)

## Configuration

Update the API base URL in `lib/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api-url.com/api/v1';
}
```

## Usage

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

3. **Test Authentication**:
   - Use the login form with valid credentials
   - Register a new account
   - Test error handling with invalid credentials

## Dependencies

- `flutter_bloc: ^9.1.1` - BLoC pattern implementation
- `equatable: ^2.0.7` - Value equality for events and states
- `http: ^1.5.0` - HTTP client for API calls

## Error Handling

The app includes comprehensive error handling:

- Network errors
- Invalid credentials
- Server errors
- Form validation errors
- Loading state management

## Security Considerations

- API tokens are stored in memory only
- Password fields are obscured
- Input validation on client side
- HTTPS for API communication

## Testing

To test the authentication flow:

1. Start the app
2. Try logging in with invalid credentials (should show error)
3. Register a new account
4. Login with valid credentials
5. Verify dashboard access
6. Test logout functionality

The app provides immediate feedback through snackbars and loading indicators for all user actions.
