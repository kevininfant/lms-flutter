// lib/widgets/auth_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class AuthForm extends StatefulWidget {
  final String formType;
  final Function(String)? onEmailCaptured;

  AuthForm({required this.formType, this.onEmailCaptured});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoading = state is AuthLoading;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.formType == 'login') ...[
              _buildInputField(
                controller: emailController,
                labelText: 'Employee ID',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 32),
              _buildAuthButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }
                        // Capture email for potential OTP flow
                        if (widget.onEmailCaptured != null) {
                          widget.onEmailCaptured!(emailController.text);
                        }

                        BlocProvider.of<AuthBloc>(context).add(
                          LoginRequested(
                            emailController.text,
                            passwordController.text,
                          ),
                        );
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ] else if (widget.formType == 'register') ...[
              _buildInputField(
                controller: emailController,
                labelText: 'Employee ID',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 32),
              _buildAuthButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }
                        if (passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                            ),
                          );
                          return;
                        }
                        BlocProvider.of<AuthBloc>(context).add(
                          RegisterRequested(
                            emailController.text,
                            passwordController.text,
                          ),
                        );
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign Up'),
              ),
            ] else if (widget.formType == 'forget') ...[
              _buildInputField(
                controller: emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              _buildAuthButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your email'),
                            ),
                          );
                          return;
                        }
                        BlocProvider.of<AuthBloc>(
                          context,
                        ).add(ForgetPasswordRequested(emailController.text));
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Email'),
              ),
            ] else if (widget.formType == 'otp') ...[
              _buildInputField(
                controller: otpController,
                labelText: 'Enter OTP',
                keyboardType: TextInputType.number,
                isOtp: true,
              ),
              const SizedBox(height: 32),
              _buildAuthButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (otpController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter OTP')),
                          );
                          return;
                        }
                        BlocProvider.of<AuthBloc>(
                          context,
                        ).add(VerifyOTPRequested(otpController.text));
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify OTP'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool isOtp = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: isOtp ? 6 : null,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: isOtp ? '' : null,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
