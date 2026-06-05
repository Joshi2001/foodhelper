import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryYellowColor = Color(0xffFFE141);
  // static const Color primaryGreenColor = Color(0xfff06410);

  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color greyWhiteColor = Color(0xffEDF2F8);

  static const MaterialColor primaryOrangeColor = MaterialColor(
    0xFFF06410, // base orange color
    <int, Color>{
      50: Color(0xFFFFEEE5),
      100: Color(0xFFFFD5BF),
      200: Color(0xFFFFB896),
      300: Color(0xFFFF9C6E), // shade300
      400: Color(0xFFFF8146),
      500: Color(0xFFF06410),
      600: Color(0xFFE1580F),
      700: Color(0xFFCC4E0D),
      800: Color(0xFFB8450C),
      900: Color(0xFFA33D0B),
    },
  );

  static const MaterialColor primaryIndigoColor = MaterialColor(
    0xFF3F51B5,
    <int, Color>{
      50: Color(0xFFE8EAF6),
      100: Color(0xFFC5CAE9),
      200: Color(0xFF9FA8DA),
      300: Color(0xFF7986CB), // shade300
      400: Color(0xFF5C6BC0),
      500: Color(0xFF3F51B5),
      600: Color(0xFF3949AB),
      700: Color(0xFF303F9F),
      800: Color(0xFF283593),
      900: Color(0xFF1A237E),
    },
  );

  static const Color redAccentColor = Colors.redAccent;
}
