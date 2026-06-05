import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _token;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userEmail => _userEmail;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userEmail = prefs.getString('userEmail');
      _isLoggedIn = _token != null && _token!.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      _isLoggedIn = false;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userEmail', email);
    
    _token = token;
    _userEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userEmail');
    
    _token = null;
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
// import 'package:flutter/material.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';

// class AuthProvider extends ChangeNotifier {
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   String? _authToken;

//   String? get authToken => _authToken;

//   Future<void> logout() async {
//     _authToken = null;
//     await _secureStorage.delete(key: 'authToken');
//     notifyListeners();
//   }

//   Future<void> getAuthToken() async {
//     _authToken = await _secureStorage.read(key: 'authToken');
//     notifyListeners();
//   }

//   static AuthProvider of(BuildContext context) =>
//       Provider.of<AuthProvider>(context, listen: false);
// }
