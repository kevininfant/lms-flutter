# JSON-Based Authentication System

This document explains the implementation of a JSON-based authentication system that reads user data from local assets instead of making HTTP API calls.

## 📁 **File Structure**

```
assets/
└── data/
    └── auth_data.json          # Authentication data
lib/
├── services/
│   └── api_service.dart        # Modified to read from JSON
├── blocs/auth/
│   └── auth_bloc.dart          # Updated authentication logic
└── models/
    └── user.dart               # User model
```

## 🗂️ **JSON Data Structure**

The `assets/data/auth_data.json` file contains:

```json
{
  "users": [
    {
      "_id": "1",
      "email": "admin@lms.com",
      "password": "admin123",
      "name": "Admin User",
      "type": "admin",
      "age": 30,
      "gender": "male",
      "mobile": "1234567890",
      "address": "123 Admin Street",
      "dob": "1993-01-01",
      "imagecode": 1
    },
    {
      "_id": "2",
      "email": "student@lms.com",
      "password": "student123",
      "name": "Student User",
      "type": "student",
      "age": 22,
      "gender": "female",
      "mobile": "0987654321",
      "address": "456 Student Avenue",
      "dob": "2001-05-15",
      "imagecode": 2
    },
    {
      "_id": "3",
      "email": "teacher@lms.com",
      "password": "teacher123",
      "name": "Teacher User",
      "type": "teacher",
      "age": 35,
      "gender": "male",
      "mobile": "1122334455",
      "address": "789 Teacher Road",
      "dob": "1988-03-20",
      "imagecode": 3
    }
  ],
  "settings": {
    "requireOTP": false,
    "maxLoginAttempts": 3,
    "sessionTimeout": 3600
  }
}
```

## 🔧 **API Service Implementation**

### **Key Features:**

1. **JSON Data Loading**: Reads authentication data from `assets/data/auth_data.json`
2. **Local User Management**: Manages users in memory during app session
3. **Token Generation**: Creates mock tokens for authenticated users
4. **Settings Integration**: Uses JSON settings for OTP requirements

### **Core Methods:**

```dart
class ApiService {
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _settings = {};
  String? _token;
  bool _isInitialized = false;

  // Initialize data from JSON
  Future<void> _initializeData() async {
    final String response = await rootBundle.loadString('assets/data/auth_data.json');
    final data = json.decode(response);
    _users = List<Map<String, dynamic>>.from(data['users']);
    _settings = data['settings'];
    _isInitialized = true;
  }

  // Login with email and password
  Future<User> login(String email, String password) async {
    await _initializeData();
    
    final user = _users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    final token = 'mock_token_${user['_id']}_${DateTime.now().millisecondsSinceEpoch}';
    _token = token;

    final userWithToken = Map<String, dynamic>.from(user);
    userWithToken['token'] = token;

    return User.fromJson(userWithToken);
  }

  // Register new user
  Future<void> register(String email, String password) async {
    await _initializeData();
    
    final existingUser = _users.any((user) => user['email'] == email);
    if (existingUser) {
      throw Exception('User already exists with this email');
    }

    final newUser = {
      '_id': (_users.length + 1).toString(),
      'email': email,
      'password': password,
      'name': email.split('@')[0],
      'type': 'student',
      // ... other fields
    };

    _users.add(newUser);
  }

  // Check if OTP is required
  bool isOTPRequired() {
    return _settings['requireOTP'] ?? false;
  }
}
```

## 🔐 **Authentication Flow**

### **Login Process:**

1. **User Input**: User enters email and password
2. **Data Loading**: API service loads JSON data from assets
3. **Validation**: Checks if user exists with matching credentials
4. **Token Generation**: Creates mock authentication token
5. **OTP Check**: Determines if OTP verification is required
6. **State Emission**: BLoC emits appropriate state (Authenticated or AuthError)

### **OTP Flow:**

1. **OTP Trigger**: If `requireOTP` is `true` in settings
2. **Error Message**: Login emits error message about OTP requirement
3. **UI Switch**: Login screen automatically switches to OTP form
4. **OTP Verification**: User enters OTP (demo: `123456` or `000000`)
5. **Authentication**: Successful OTP leads to authenticated state

## 🎯 **Demo Credentials**

### **Pre-configured Users:**

| Email | Password | Type | Name |
|-------|----------|------|------|
| `admin@lms.com` | `admin123` | admin | Admin User |
| `student@lms.com` | `student123` | student | Student User |
| `teacher@lms.com` | `teacher123` | teacher | Teacher User |

### **OTP Codes:**
- `123456` - Valid OTP
- `000000` - Valid OTP
- Any other code - Invalid OTP

## ⚙️ **Settings Configuration**

### **OTP Settings:**
```json
"settings": {
  "requireOTP": false,        // Set to true to enable OTP requirement
  "maxLoginAttempts": 3,      // Maximum login attempts
  "sessionTimeout": 3600      // Session timeout in seconds
}
```

### **Enabling OTP:**
To enable OTP verification:
1. Change `"requireOTP": false` to `"requireOTP": true` in JSON
2. Restart the app
3. Login will now require OTP verification

## 🚀 **Usage Examples**

### **Adding New Users:**

1. **Edit JSON File**: Add new user to `users` array in `auth_data.json`
2. **Restart App**: New user will be available immediately
3. **Test Login**: Use new credentials to test authentication

### **Modifying User Data:**

1. **Update JSON**: Modify user data in `auth_data.json`
2. **Restart App**: Changes take effect immediately
3. **Verify Changes**: Login with updated user to see changes

### **Customizing Settings:**

1. **Edit Settings**: Modify `settings` object in JSON
2. **Restart App**: New settings applied immediately
3. **Test Features**: Verify OTP and other settings work

## 🔄 **Data Persistence**

### **Session-Only Data:**
- User modifications during app session are stored in memory
- Changes are lost when app is restarted
- JSON file remains unchanged during runtime

### **Permanent Changes:**
- To make permanent changes, edit the JSON file directly
- Restart the app to apply permanent changes
- JSON file serves as the source of truth

## 🛠️ **Development Benefits**

### **Advantages:**
1. **No Network Required**: Works offline
2. **Fast Development**: No API setup needed
3. **Easy Testing**: Pre-configured test users
4. **Flexible**: Easy to modify user data
5. **Demo Ready**: Perfect for demonstrations

### **Use Cases:**
- **Prototyping**: Quick authentication setup
- **Testing**: Consistent test data
- **Demos**: Reliable demo scenarios
- **Offline Apps**: No internet dependency

## 📱 **Testing the System**

### **Test Scenarios:**

1. **Valid Login**: Use demo credentials to login
2. **Invalid Login**: Try wrong credentials
3. **Registration**: Create new user account
4. **OTP Flow**: Enable OTP and test verification
5. **User Management**: Test user data updates

### **Expected Behavior:**

- **Successful Login**: Navigates to dashboard
- **Failed Login**: Shows error message
- **OTP Required**: Switches to OTP form
- **Invalid OTP**: Shows error message
- **Valid OTP**: Completes authentication

## 🔧 **Customization Options**

### **Adding Fields:**
1. **Update JSON**: Add new fields to user objects
2. **Update Model**: Modify `User` model if needed
3. **Update Service**: Handle new fields in API service

### **Adding Features:**
1. **New Settings**: Add to settings object in JSON
2. **New Methods**: Add methods to API service
3. **New Events**: Add events to auth BLoC

## ✅ **Implementation Complete**

The JSON-based authentication system is now fully implemented with:

✅ **JSON Data Source**: Authentication data from assets
✅ **Local User Management**: In-memory user operations
✅ **Mock Token System**: Generated authentication tokens
✅ **OTP Integration**: Configurable OTP requirements
✅ **Settings Support**: Flexible configuration options
✅ **Demo Users**: Pre-configured test accounts
✅ **Error Handling**: Proper error messages
✅ **Offline Support**: No network dependency

## 🚀 **Next Steps**

1. **Add Your Users**: Edit `auth_data.json` with your user data
2. **Configure Settings**: Adjust OTP and other settings
3. **Test Authentication**: Try all login scenarios
4. **Customize Fields**: Add any additional user fields needed
5. **Production Ready**: System is ready for development and testing

The authentication system now works entirely with local JSON data, providing a fast, reliable, and offline-capable authentication experience!
