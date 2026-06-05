import 'package:e_commerce/Screens/coupon/coupon_model.dart';
import 'package:e_commerce/Screens/coupon/coupons_screeen.dart';
import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplyCouponOnCartCard extends StatelessWidget {
  const ApplyCouponOnCartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apply Coupon',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          if (couponProvider.isCouponApplied) ...[
            // Show applied coupon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon Applied: ${couponProvider.appliedCouponCode}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'You saved ₹${couponProvider.discountAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      couponProvider.removeCoupon();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coupon removed'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show apply coupon button
            InkWell(
              onTap: () async {
                // Get order total from cart
                final homeProvider = Provider.of<Home>(context, listen: false);
                final cartItems = homeProvider.getCartItemsLocal();
                final subtotal = cartItems.fold<double>(0, (sum, item) {
                  return sum + (homeProvider.getFinalPrice(item.product, item.quantity) * item.quantity);
                });
                
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CouponsSelectionScreen(
                      orderTotal: subtotal,
                    ),
                  ),
                );
                
                if (result != null && result is ApplyCouponResponse) {
                  if (result.success && result.couponCode != null) {
                    // Apply coupon to provider
                    couponProvider.applyCoupon(
                      couponCode: result.couponCode!,
                      discountAmount: result.discountAmount,
                      orderTotal: subtotal,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message.isNotEmpty ? result.message : 'Coupon applied successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (!result.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message.isNotEmpty ? result.message : 'Invalid coupon code'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryOrangeColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primaryOrangeColor.withOpacity(0.05),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined, 
                        color: AppColors.primaryOrangeColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apply Coupon Code',
                      style: TextStyle(
                        color: AppColors.primaryOrangeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, 
                        color: AppColors.primaryOrangeColor, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Import this at the top of the file
// import 'package:e_commerce/Screens/coupon/coupon_model.dart';
// import 'package:e_commerce/Screens/coupon/coupon_model.dart';
// import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
// import 'package:e_commerce/Screens/coupon/coupon_service.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ApplyCouponOnCartCard extends StatefulWidget {
//   const ApplyCouponOnCartCard({super.key});

//   @override
//   State<ApplyCouponOnCartCard> createState() => _ApplyCouponOnCartCardState();
// }

// class _ApplyCouponOnCartCardState extends State<ApplyCouponOnCartCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CouponProvider>(
//       builder: (context, couponProvider, _) {
//         print('🔍 CouponProvider State - isApplied: ${couponProvider.isCouponApplied}, code: ${couponProvider.appliedCouponCode}, discount: ${couponProvider.discountAmount}');

//         if (couponProvider.isCouponApplied && couponProvider.appliedCouponCode != null && couponProvider.appliedCouponCode!.isNotEmpty) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.green.shade200),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.local_offer, color: Colors.green, size: 20),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '"${couponProvider.appliedCouponCode}" applied!',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Colors.green,
//                         ),
//                       ),
//                       Text(
//                         'You saved ₹${couponProvider.discountAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(fontSize: 12, color: Colors.green),
//                       ),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     couponProvider.removeCoupon();
//                     // Force UI refresh
//                     setState(() {});
//                   },
//                   child: const Icon(Icons.close, color: Colors.red, size: 20),
//                 ),
//               ],
//             ),
//           );
//         }

//         return GestureDetector(
//           onTap: () async {
//             final homeProvider = Provider.of<Home>(context, listen: false);
//             final cartItems = homeProvider.getCartItemsLocal();
//             final subtotal = cartItems.fold<double>(0, (sum, item) {
//               return sum + (homeProvider.getFinalPrice(item.product, item.quantity) * item.quantity);
//             });

//             print('💰 Cart Subtotal: $subtotal');

//             final result = await Navigator.pushNamed(
//               context,
//               '/coupons',
//               arguments: subtotal,
//             );
//             print('📌 Navigation Result: $result');
//             print('📌 Result type: ${result.runtimeType}');

//             // Handle the result - expecting ApplyCouponResponse
//             if (result != null && result is ApplyCouponResponse) {
//               print('📌 Coupon Code from response: ${result.couponCode}');
//               print('📌 Discount Amount: ${result.discountAmount}');
//               print('📌 Success: ${result.success}');

//               if (result.success && result.couponCode != null && result.couponCode!.isNotEmpty) {
//                 // Apply the coupon with the actual coupon code from the response
//                 couponProvider.applyCoupon(
//                   couponCode: result.couponCode!,
//                   discountAmount: result.discountAmount,
//                   orderTotal: subtotal,
//                 );

//                 // Force UI refresh
//                 setState(() {});

//                 // Show success message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(result.message),
//                     backgroundColor: Colors.green,
//                     duration: const Duration(seconds: 2),
//                   ),
//                 );
//               } else {
//                 // Show error message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(result.message),
//                     backgroundColor: Colors.red,
//                     duration: const Duration(seconds: 3),
//                   ),
//                 );
//               }
//             } else if (result != null && result is String) {
//               // If somehow a string is returned, try to apply it directly
//               if (result.isNotEmpty) {
//                 couponProvider.applyCoupon(
//                   couponCode: result,
//                   discountAmount: 0,
//                   orderTotal: subtotal,
//                 );
//                 setState(() {});
//               }
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.local_offer_outlined,
//                     color: AppColors.primaryOrangeColor, size: 20),
//                 const SizedBox(width: 10),
//                 const Expanded(
//                   child: Text(
//                     'Apply Coupon',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 Icon(Icons.arrow_forward_ios,
//                     size: 14, color: Colors.grey.shade500),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
