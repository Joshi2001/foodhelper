// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import '../../../cart_provider.dart';
// import '../../../Services/Providers/cart_provider.dart';
// import '../Atoms/card_individual_price.dart';

// class CartPriceDetailWidget extends StatelessWidget {
//   const CartPriceDetailWidget({
//     super.key,
//   });
//   void showGstSplitDialog(BuildContext context, int gstPercent) {
//     double half = gstPercent / 2;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           title: Text("GST Split Details"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               gstRow("Total GST", "$gstPercent%"),
//               SizedBox(height: 10),
//               gstRow("CGST", "${half.toStringAsFixed(1)}%"),
//               gstRow("SGST", "${half.toStringAsFixed(1)}%"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Close"),
//             )
//           ],
//         );
//       },
//     );
//   }

//   Widget gstRow(String title, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title, style: TextStyle(fontSize: 16)),
//         Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {
//         return InkWell(
//           onTap: (){
//             showGstSplitDialog(context,18);
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 10),
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//             decoration: BoxDecoration(
//                 color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Bill Details",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//                 ListView.builder(
//                   itemCount: cartProvider.billDetails.length,
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemBuilder: (BuildContext context, int index) {
//                     final detail = cartProvider.billDetails[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(detail["title"]),
//                           Text(
//                             detail["amount"] < 0
//                                 ? "-₹${(-detail["amount"]).toStringAsFixed(0)}"
//                                 : "₹${detail["amount"].toStringAsFixed(0)}",
//                             style: TextStyle(
//                               color: detail["amount"] < 0
//                                   ? Colors.green
//                                   : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Grand Total",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Text(
//                       "₹${cartProvider.grandTotal.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
