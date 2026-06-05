// // add_address_detalis.dart

// import 'package:flutter/material.dart';

// class AddAddressScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>)? onAddressSelected;
//   final String? preSelectedLocation;
//   final Map<String, dynamic>? preSelectedLatLng;

//   const AddAddressScreen({
//     super.key,
//     this.onAddressSelected,
//     this.preSelectedLocation,
//     this.preSelectedLatLng,
//   });

//   @override
//   State<AddAddressScreen> createState() => _AddAddressScreenState();
// }

// class _AddAddressScreenState extends State<AddAddressScreen> {
//   final TextEditingController houseController = TextEditingController();
//   final TextEditingController buildingController = TextEditingController();
//   final TextEditingController landmarkController = TextEditingController();
//   final TextEditingController receiverNameController = TextEditingController();
//   final TextEditingController receiverPhoneController = TextEditingController();
  
//   String? selectedAddress;
//   Map<String, dynamic>? selectedLatLng;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill with data from location picker
//     if (widget.preSelectedLocation != null) {
//       selectedAddress = widget.preSelectedLocation;
//     }
//     if (widget.preSelectedLatLng != null) {
//       selectedLatLng = widget.preSelectedLatLng;
//     }
//   }

//   @override
//   void dispose() {
//     houseController.dispose();
//     buildingController.dispose();
//     landmarkController.dispose();
//     receiverNameController.dispose();
//     receiverPhoneController.dispose();
//     super.dispose();
//   }

//   void _saveAddress() {
//   // Validate required fields
//   if (houseController.text.trim().isEmpty) {
//     _showError("Please enter house/flat number");
//     return;
//   }
//   if (buildingController.text.trim().isEmpty) {
//     _showError("Please enter building/apartment name");
//     return;
//   }
//   if (receiverNameController.text.trim().isEmpty) {
//     _showError("Please enter receiver's name");
//     return;
//   }
//   if (receiverPhoneController.text.trim().isEmpty) {
//     _showError("Please enter receiver's phone number");
//     return;
//   }
//   if (selectedAddress == null) {
//     _showError("Please select a location first");
//     return;
//   }

//   final result = {
//     "address": selectedAddress,
//     "location": selectedLatLng,
//     "house": houseController.text.trim(),
//     "building": buildingController.text.trim(),
//     "landmark": landmarkController.text.trim(),
//     "receiverName": receiverNameController.text.trim(),
//     "receiverPhone": receiverPhoneController.text.trim(),
//   };

//   // Show success message
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(
//       content: Text("Address saved successfully!"),
//       backgroundColor: Colors.green,
//       duration: Duration(seconds: 2),
//     ),
//   );

//   // Wait for snackbar to be visible then pop
//   Future.delayed(const Duration(milliseconds: 500), () {
//     if (widget.onAddressSelected != null) {
//       widget.onAddressSelected!(result);
//       Navigator.pop(context);
//     } else {
//       Navigator.pop(context, result);
//     }
//   });
// }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   Widget _textField(String label, TextEditingController controller, 
//       {bool optional = false, TextInputType keyboardType = TextInputType.text}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label + (optional ? " (Optional)" : " *"),
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: "Enter $label",
//             filled: true,
//             fillColor: Colors.grey[50],
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.red, width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Add Delivery Address"),
//           backgroundColor: Colors.red,
//           foregroundColor: Colors.white,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Display selected location
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.location_on, color: Colors.green),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Selected Location",
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.green,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             selectedAddress ?? "No location selected",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.green),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               const Text(
//                 "Address Details",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
              
//               _textField("House/Flat No.", houseController),
//               const SizedBox(height: 12),
              
//               _textField("Building/Apartment Name", buildingController),
//               const SizedBox(height: 12),
              
//               _textField("Landmark", landmarkController, optional: true),
//               const SizedBox(height: 12),
              
//               _textField("Receiver's Name", receiverNameController),
//               const SizedBox(height: 12),
              
//               _textField("Receiver's Phone Number", receiverPhoneController, 
//                   keyboardType: TextInputType.phone),
//               const SizedBox(height: 24),
              
//               ElevatedButton(
//                 onPressed: _saveAddress,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "SAVE ADDRESS",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
