// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../Services/Providers/cart_provider.dart';
// import '../../../app_colors.dart';

// class CartTimeandTotalItemCard extends StatelessWidget {
//   const CartTimeandTotalItemCard({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10.0),
//               topRight: Radius.circular(10.0),
//             ),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.lock_clock,
//                 color: AppColors.primaryOrangeColor,
//               ),
//               const SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Delivery in ${cartProvider.deliveryTime}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text('${cartProvider.totalItemsCount} Items')
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
