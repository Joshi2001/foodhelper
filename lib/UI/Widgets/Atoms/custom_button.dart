import 'package:flutter/material.dart';
import '../../../app_colors.dart';

Widget customTextButton(
  BuildContext context, {
  String? title = "Continue",
  required VoidCallback? callback,
  EdgeInsets? padding,
  Color? color,
  EdgeInsets? margin,
  Widget? child,
}) {
  return Container(
    margin: margin,
    child: ElevatedButton(
      onPressed: callback, 
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.redAccentColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        padding: padding,
      ),
      child: child ??
          Text(
            title ?? 'Continue',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12
            ),
          ),
    ),
  );
}

// import 'package:flutter/material.dart';

// import '../../../app_colors.dart';

// Widget customTextButton(
//   context, {
//   String? title = "Continue",
//   required Function callback,
//   EdgeInsets? padding,
//   Color? color,
//   EdgeInsets? margin,
// }) =>
//     ElevatedButton(
//       onPressed: () => callback(),
//       style: TextButton.styleFrom(
//         backgroundColor: color ?? AppColors.redAccentColor,
//         foregroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(10.0),
//           ),
//         ),
//         padding: padding,
//       ),
//       child: Text(
//         title ?? 'Continue',
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
