import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/learning_illustration.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _currentFormType = 'login';
  String _title = 'Learn More';
  String _subtitle = 'Experience More';
  String _userEmail = '';

  void _switchForm(String formType) {
    setState(() {
      _currentFormType = formType;
      switch (formType) {
        case 'login':
          _title = 'Learn More';
          _subtitle = 'Experience More';
          break;
        case 'register':
          _title = 'Create Account';
          _subtitle = 'Join our learning community';
          break;
        case 'forget':
          _title = 'Reset Password';
          _subtitle = 'Enter your email to receive reset instructions';
          break;
        case 'otp':
          _title = 'Verify OTP';
          _subtitle = 'Enter the 6-digit code sent to $_userEmail';
          break;
      }
    });
  }

  void _switchToOTPForm() {
    setState(() {
      _currentFormType = 'otp';
      _title = 'Verify OTP';
      _subtitle = 'Enter the 6-digit code sent to $_userEmail';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Welcome ${state.user.name ?? state.user.email}!",
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Navigation will be handled by the main app's BlocBuilder
          } else if (state is AuthError) {
            // Check if error indicates OTP is required
            if (state.message.toLowerCase().contains('otp') ||
                state.message.toLowerCase().contains('verification')) {
              // Show OTP form instead of error message
              _switchToOTPForm();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with illustration
              const LearningIllustration(),

              // Title and subtitle
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Auth form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AuthForm(
                  formType: _currentFormType,
                  onEmailCaptured: (email) {
                    _userEmail = email;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Navigation buttons based on current form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildNavigationButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    switch (_currentFormType) {
      case 'login':
        return Column(
          children: [
            // Forgot Password - ABOVE login button
            TextButton(
              onPressed: () => _switchForm('forget'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),

            // Sign Up - BELOW login area
            TextButton(
              onPressed: () => _switchForm('register'),
              child: Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        );

      case 'register':
        return Column(
          children: [
            // Terms and conditions for register
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                children: [
                  const TextSpan(
                    text: 'By creating an account, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => _switchForm('login'),
              child: Text(
                'Already have an account? Login',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        );

      case 'forget':
        return Column(
          children: [
            TextButton(
              onPressed: () => _switchForm('login'),
              child: Text(
                'Remember your password? Login',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        );

      case 'otp':
        return Column(
          children: [
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Resend OTP feature coming soon!'),
                      ),
                    );
                  },
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            TextButton(
              onPressed: () => _switchForm('login'),
              child: Text(
                'Back to Login',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
