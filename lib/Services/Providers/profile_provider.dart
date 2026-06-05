
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userPhone = '';
  String _profileImage = '';
  bool _isLoggedIn = false;
  String _selectedLocation = 'Select your location';
  String _authToken = ''; // ✅ ADDED

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get profileImage => _profileImage;
  bool get isLoggedIn => _isLoggedIn;
  String get selectedLocation => _selectedLocation;
  String get authToken => _authToken; // ✅ ADDED

  // Update user info
  void updateUserInfo({
    required String name,
    required String email,
    required String phone,
    String? image,
    String? token, // ✅ ADDED
  }) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    if (image != null) _profileImage = image;
    if (token != null) _authToken = token; // ✅ ADDED
    _isLoggedIn = true;
    notifyListeners();
  }

  // Update location
  void updateLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  // Logout
  void logout() {
    _userName = 'Guest User';
    _userEmail = '';
    _userPhone = '';
    _profileImage = '';
    _isLoggedIn = false;
    _authToken = ''; // ✅ ADDED
    notifyListeners();
  }
}

// class ProfileProvider with ChangeNotifier {
//   String _userName = 'Guest User';
//   String _userEmail = '';
//   String _userPhone = '';
//   String _profileImage = '';
//   bool _isLoggedIn = false;
//   String _selectedLocation = 'Select your location';

//   // Getters
//   String get userName => _userName;
//   String get userEmail => _userEmail;
//   String get userPhone => _userPhone;
//   String get profileImage => _profileImage;
//   bool get isLoggedIn => _isLoggedIn;
//   String get selectedLocation => _selectedLocation;

//   // Update user info
//   void updateUserInfo({
//     required String name,
//     required String email,
//     required String phone,
//     String? image,
//   }) {
//     _userName = name;
//     _userEmail = email;
//     _userPhone = phone;
//     if (image != null) _profileImage = image;
//     _isLoggedIn = true;
//     notifyListeners();
//   }

//   // Update location
//   void updateLocation(String location) {
//     _selectedLocation = location;
//     notifyListeners();
//   }

//   // Logout
//   void logout() {
//     _userName = 'Guest User';
//     _userEmail = '';
//     _userPhone = '';
//     _profileImage = '';
//     _isLoggedIn = false;
//     notifyListeners();
//   }
// }
