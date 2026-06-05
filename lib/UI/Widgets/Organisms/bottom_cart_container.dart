
import 'package:e_commerce/Screens/user_cart_screen.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_colors.dart';
import 'bottom_cart_sheet.dart';

class BottomStickyContainer extends StatelessWidget {
  const BottomStickyContainer({super.key, this.isOpen = false});
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, provider, child) {
        final totalItems = provider.totalCartItems;
        //final totalItems = provider.totalCartItems;
        final totalPrice = provider.totalCartPrice;
final basePrice = provider.baseCartPrice;
        // Calculate total price from cart items
        // double totalPrice = 0;
        // try {
        //   if (provider.cartItems.isNotEmpty) {
        //     totalPrice = provider.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
        //   }
        // } catch (e) {
        //   print('Error calculating total price: $e');
        // }

        if (totalItems == 0) {
          return const SizedBox.shrink();
        }
        print('Total Price: ${provider.totalCartPrice}');

        return GestureDetector(
          onTap: () => isOpen ? null : showCartBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  isOpen
                      ? const SizedBox(width: 28)
                      : Icon(
                          Icons.keyboard_arrow_up,
                          size: 28,
                          color: AppColors.primaryOrangeColor,
                        ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 26,
                        color: AppColors.primaryOrangeColor,
                      ),
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrangeColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$totalItems',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Expanded(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text(
                  //         "₹${totalPrice.toStringAsFixed(0)}",
                  //         style: const TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       Text(
                  //         '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           color: Colors.grey[600],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "₹${totalPrice.toStringAsFixed(0)}",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Text(
      //   "MRP ₹${basePrice.toStringAsFixed(0)}",
      //   style: TextStyle(
      //     fontSize: 12,
      //     color: Colors.grey[600],
      //     decoration: TextDecoration.lineThrough,
      //   ),
      // ),
      Text(
        '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  ),
),
                  ElevatedButton(
  onPressed: () async {
    final home = context.read<Home>();

    await home.loadCart();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrangeColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 0,
  ),
  child:  Row(
    children: [
      Text(
        'Checkout',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward, color: Colors.white),
  ],
    ),
                
),

                ]    
              ),
            ),
          ),
        );
      },
    );
  }
}
