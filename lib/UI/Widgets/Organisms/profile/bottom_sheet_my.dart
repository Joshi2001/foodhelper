// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class CartBottomNavBar extends StatelessWidget {
//   const CartBottomNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Home>(
//       builder: (context, homeProvider, _) {
//         final totalItems = homeProvider.totalCartItems;
//         final cartItems = homeProvider.getCartItemsLocal();
//         print(totalItems);
//         if (totalItems == 0) {
//           return const SizedBox.shrink();
//         }

//         // final totalPrice = cartItems.fold<double>(
//         //   0,
//         //   (sum, item) => sum + item.totalPrice,
//         // );
//         final totalCartPrice = homeProvider.totalCartPrice;

// print("total prices $totalCartPrice");
//         return Positioned(
//           left: 0,
//           right: 0,
//           bottom: 0,
//           child: SafeArea(
//             top: false,
//             child: GestureDetector(
//               onTap: () => showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => const BottomStickyContainer(),
//               ),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     /// CART ICON + COUNT
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Icon(
//                           Icons.shopping_cart_outlined,
//                           size: 26,
//                           color: AppColors.primaryOrangeColor,
//                         ),
//                         Positioned(
//                           right: -6,
//                           top: -6,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: AppColors.primaryOrangeColor,
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: const BoxConstraints(
//                               minWidth: 18,
//                               minHeight: 18,
//                             ),
//                             child: Text(
//                               "$totalItems",
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(width: 12),

//                     /// PRICE INFO
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "₹ ${totalCartPrice.toStringAsFixed(0)}",
//                             style: const TextStyle(
//                               fontSize: 17,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             "$totalItems items",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     /// CHECKOUT BUTTON
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, "/cart");
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             AppColors.primaryOrangeColor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Row(
//                         children: [
//                           Text(
//                             "Checkout",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 6),
//                           Icon(Icons.arrow_forward,
//                               size: 16, color: Colors.white),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
