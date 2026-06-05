import 'package:flutter/material.dart';
const kBorderTextField = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.grey, width: 1.0),
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
);
Widget customTextField({
  TextEditingController? textEditingController,
  String? hintText,
  bool isPhoneNumberField = false,
  String? prefix = "",
  int? maxLength,
  String? Function(String?)? validator,
  void Function(String)? onFieldSubmitted,
  Widget? suffixIcon,
  Color? backgroundColor,
  bool? isAutoFocus,
  IconData? prefixIcon,
  required TextInputType keyboardType,
  bool? isPassword,
}) =>
    TextFormField(
      controller: textEditingController,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: isAutoFocus ?? false,
      cursorColor: Colors.grey,


      maxLength: isPhoneNumberField ? (maxLength ?? 10) : null,

      keyboardType:
          isPhoneNumberField ? TextInputType.phone : keyboardType,

      textCapitalization:
          isPhoneNumberField ? TextCapitalization.none : TextCapitalization.none,

      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        enabledBorder: kBorderTextField,
        focusedBorder: kBorderTextField,
        disabledBorder: kBorderTextField,
        errorBorder: kBorderTextField,
        focusedErrorBorder: kBorderTextField,
        hintText: hintText,
        fillColor: backgroundColor ?? Colors.white,
        filled: true,

        // ✅ Show prefix ONLY for phone field
        prefix: isPhoneNumberField
            ? Text(
                prefix ?? "+91  ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,

        suffixIcon: suffixIcon ??
            (textEditingController == null
                ? null
                : IconButton(
                    onPressed: () => textEditingController.clear(),
                    icon: const Icon(Icons.cancel, color: Colors.black),
                  )),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );

// import 'package:flutter/material.dart';

// const kBorderTextField = OutlineInputBorder(
//   borderSide: BorderSide(color: Colors.grey, width: 1.0),
//   borderRadius: BorderRadius.all(Radius.circular(8.0)),
// );

// Widget customTextField({
//   TextEditingController? textEditingController,
//   String? hintText,
//   bool isPhoneNumberField = false,
//   String? prefix = "",
//   int? maxLength = 10,
//   String? Function(String?)? validator,
//   String? Function(String?)? onFieldSubmitted,
//   Widget? suffixIcon,
//   Color? backgroundColor,
//   bool? isAutoFocus,  IconData? prefixIcon, required TextInputType keyboardType,  bool? isPassword,
// }) =>
//     TextFormField(
//       onFieldSubmitted: onFieldSubmitted,
//       controller: textEditingController,
//       maxLength: maxLength,
//       validator: validator,
//       textCapitalization: TextCapitalization.characters,
//       autofocus: isAutoFocus ?? true,
//       cursorColor: Colors.grey,
//       keyboardType:
//           isPhoneNumberField ? TextInputType.phone : TextInputType.text,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
//         enabledBorder: kBorderTextField,
//         focusedBorder: kBorderTextField,
//         disabledBorder: kBorderTextField,
//         errorBorder: kBorderTextField,
//         focusedErrorBorder: kBorderTextField,
//         hintText: hintText ?? 'Enter Mobile Number',
//         fillColor: backgroundColor ?? Colors.white,
//         filled: true,
//         prefix: Text(
//           prefix ?? "+91  ",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         suffixIcon: suffixIcon ??
//             IconButton(
//               onPressed: () => textEditingController!.clear(),
//               icon: const Icon(
//                 Icons.cancel,
//                 color: Colors.black,
//               ),
//             ),
//       ),
//       style: const TextStyle(fontWeight: FontWeight.bold),
//     );
