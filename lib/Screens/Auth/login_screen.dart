import 'dart:convert';
import 'package:e_commerce/Services/Providers/auth.provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/custom_button.dart';
import 'package:e_commerce/UI/Widgets/Atoms/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_colors.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override 
  State<LoginScreen> createState() => _LoginScreenState();
} 

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.red, Colors.green, Colors.yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "FoodHelper",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Welcome to the FoodHelper',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Instant APP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: customTextButton(
                    context,
                    title: "Continue",
                    callback: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        isDismissible: true, 
                        enableDrag: true,
                        builder: (context) => const LoginWithEmailWidget(),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Text(
                  'By continuing, you agree to our terms of service and privacy policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginWithEmailWidget extends StatefulWidget {
  const LoginWithEmailWidget({super.key});

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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
      if (pass.length < 6) {
        _showErrorDialog(context, 'Password must be at least 6 characters');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<Home>().apiService;
      final String endpoint = _isSignUp ? '/api/user/signup' : '/api/user/login';

      final Map<String, dynamic> body = _isSignUp
          ? {"name": name, "phone": phone, "email": email, "password": pass}
          : {"email": email, "password": pass};

      final response = await http.post(
        Uri.parse('${apiService.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        if (_isSignUp && response.statusCode == 201) {
          await _showSuccessDialog(
            context,
            'Signup successful! Please login to continue.',
            () {
              Navigator.pop(context);
              setState(() {
                _isSignUp = false;
                _emailController.text = email;
              });
            },
          );
          return;
        }

        if (!_isSignUp && response.statusCode == 200 && data['token'] != null) {
          // Login with AuthProvider
          final authProvider = context.read<AuthProvider>();
          await authProvider.login(data['token'], email);
          
          if (!mounted) return;
          
          // Close all bottom sheets and dialogs
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          // Navigate to home
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showErrorDialog(context, data['message'] ?? 'Request failed');
      }
    } catch (e) {
      print('Auth error: $e');
      _showErrorDialog(context, 'Something went wrong. Please try again.');
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
        ),
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
            
            if (_isSignUp) ...[
              customTextField(
                hintText: 'Enter your full name',
                textEditingController: _nameController,
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              customTextField(
                hintText: 'Enter your phone number',
                textEditingController: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
            ],

            customTextField(
              hintText: 'Enter your email',
              textEditingController: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            customTextField(
              hintText: 'Enter your password',
              textEditingController: _passwordController,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 20),

            customTextButton(
              context,
              callback: _isLoading ? null : () => _authorizeWithEmail(context),
              color: AppColors.primaryOrangeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  style: const TextStyle(color: Colors.grey),
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
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
// import 'package:e_commerce/UI/Widgets/Atoms/custom_button.dart';
// import 'package:e_commerce/UI/Widgets/Organisms/login_screen_otp_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override 
//   State<LoginScreen> createState() => _LoginScreenState();
// } 

// class _LoginScreenState extends State<LoginScreen> 
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         body: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   'Assets/auth.json',
//                   controller: _controller,
//                   onLoaded: (composition) {
//                     _controller
//                       ..duration = composition.duration
//                       ..forward();
//                     _controller.repeat();
//                   },
//                   repeat: true,
//                   frameRate: FrameRate.max,
//                 ),
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [Colors.red, Colors.green, Colors.yellow],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ).createShader(bounds),
//                   child: const Text(
//                     "FoodHelper",
//                     style: TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 15,
//                 ),
//                 const Text(
//                   'Welcome to the FoodHelper',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Text(
//                   'Instant APP',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w300,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 15,
//                 ),
//                Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//   child: customTextButton(
//     context,
//     title: "Continue",
//     callback: () {
//       showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.transparent,
//         isScrollControlled: true,
//         isDismissible: true, 
//         enableDrag: true,
//         builder: (context) => const LoginWithEmailWidget(),
//       );
//     },
//   ),
// ),
//                 const Divider(),
//                 const Text(
//                   'By continuing, you agree to our terms of service and privacy policy',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
