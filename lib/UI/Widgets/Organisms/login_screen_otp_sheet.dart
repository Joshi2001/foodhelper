import 'dart:convert';

import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_colors.dart';
import '../Atoms/custom_button.dart';
import '../Atoms/custom_text_field.dart';
import 'package:http/http.dart' as http;

class LoginWithEmailWidget extends StatefulWidget {
  const LoginWithEmailWidget({
    super.key,
  });

  @override
  State<LoginWithEmailWidget> createState() => _LoginWithEmailWidgetState();
}

class _LoginWithEmailWidgetState extends State<LoginWithEmailWidget> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController; 
  late TextEditingController _phoneController;

  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
  }

  Future<void> _authorizeWithEmail(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showErrorDialog(context, 'Please enter a valid email address');
      return;
    }

    if (_isSignUp) {
      if (name.isEmpty || phone.isEmpty) {
        _showErrorDialog(context, 'Please fill all signup fields');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<Home>().apiService;

      final String endpoint =
          _isSignUp ? '/api/user/signup' : '/api/user/login';

      final Map<String, dynamic> body = _isSignUp
          ? {"name": name, "phone": phone, "email": email, "password": pass}
          : {
              "email": email,
              "password": pass,
            };

      final response = await http.post(
        Uri.parse('${apiService.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      print("STATUS CODE => ${response.statusCode}");
print("RESPONSE BODY => ${response.body}");
      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        if (!mounted) return;

        print('API SUCCESS → $endpoint');
        print(response.body);
        if (_isSignUp && response.statusCode == 201) {
          await _showSuccessDialog(
            context,
            'Signup successful! Please login to continue.',
            () {
              Navigator.pop(context); 
              setState(() {
                _isSignUp = false; 
              });
            },
          );
          return;
        }

        if (!_isSignUp && response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          print("TOKEN SAVED => ${prefs.getString('token')}");
        }
        
        Navigator.of(context).popAndPushNamed(
          '/home',
          arguments: {
            "email": email,
            "isSignUp": _isSignUp,
          },
        );
      } else {
        print(data['message']);
        _showErrorDialog(
          context,
          data['message'] ?? 'Request failed',
        );
      }
    } catch (e) {
      print(e);
      _showErrorDialog(
        context,
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSignUp ? 'Create Account' : 'Log in to Your Account',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Name & Phone fields (Signup only)
              if (_isSignUp) ...[
                customTextField(
                  hintText: 'Enter your full name',
                  textEditingController: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                customTextField(
                  hintText: 'Enter your phone number',
                  textEditingController: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone number";
                    }
                    if (value.length < 10) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],

              customTextField(
                hintText: 'Enter your email',
                textEditingController: _emailController,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              customTextField(
                hintText: 'Enter your password',
                textEditingController: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  if (_isSignUp && value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
              ),

              const SizedBox(height: 20),

              customTextButton(
                context,
                callback:
                    _isLoading ? null : () => _authorizeWithEmail(context),
                color: AppColors.primaryOrangeColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isSignUp ? 'Sign Up' : 'Log In',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp
                        ? 'Already have an account?'
                        : 'Don\'t have an account?',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleSignUp,
                    child: Text(
                      _isSignUp ? 'Log In' : 'Sign Up',
                      style: TextStyle(
                        color: AppColors.primaryOrangeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'By continuing, you agree to our terms of service and privacy policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    String message,
    VoidCallback onOk,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onOk,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
