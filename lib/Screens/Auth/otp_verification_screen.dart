import 'dart:async';
import 'dart:convert';

import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/custom_text_field.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key, this.data});

  final dynamic data;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late TextEditingController _otpController;
  int _secondsRemaining = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startTimer();
  }

  // Future _verifyOTP(context, value) async {
  //   return Navigator.of(context).pushNamedAndRemoveUntil(
  //     '/home',
  //     (route) => false,
  //   );
  // }
 Future<void> _verifyOTP(BuildContext context, String otp) async {
  final apiService = context.read<Home>().apiService;
  final url = Uri.parse(
    '${apiService.baseUrl}/api/user/verify-otp',
  );

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": widget.data['email'],
        "otp": otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      if (!mounted) return;
      print(response.statusCode);
      print(response.body);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      ); 
    } else {
      print("${data['message']}");
      _showErrorDialog(context, data['message'] ?? 'Invalid OTP');
    }
  } catch (e) {
    print(e);
    _showErrorDialog(context, 'Something went wrong. Try again.');
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


  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_secondsRemaining == 1) {
          timer.cancel();
          setState(() {});
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  void _restartTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _secondsRemaining = 30;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP verification'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("We've sent a verification code to "),
              Text(
                "+91 ${widget.data['phoneNumber']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Enter the code below to verify your account"),
              const SizedBox(
                height: 10,
              ),
              customTextField(
                hintText: "Please enter OTP",
                isPhoneNumberField: true,
                maxLength: 6,
                textEditingController: _otpController,
                onFieldSubmitted: (value) {
                  _verifyOTP(context, value);
                  return null;
                }, keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 10,
              ),
              _timer.isActive
                  ? Text(
                      'Resend OTP in $_secondsRemaining',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(),
              _timer.isActive == false
                  ? TextButton(
                      onPressed: _restartTimer,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: AppColors.primaryOrangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
