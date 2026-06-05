import 'package:e_commerce/Services/Providers/auth.provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:e_commerce/UI/Widgets/Organisms/login_screen_otp_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/cart_item.dart';
import '../../../app_colors.dart';

void showCartBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CartBottomSheet(),
  );
}

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceedToCheckout(BuildContext context, List<CartItem> cartItems) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if user is logged in using AuthProvider
    final authProvider = context.read<AuthProvider>();

    if (!mounted) return;

    if (!authProvider.isLoggedIn) {
      // Close cart bottom sheet
      Navigator.pop(context);
      
      // Show login bottom sheet
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => const LoginWithEmailWidget(),
      );
      
      // After returning from login, check again if user is logged in
      if (mounted && context.read<AuthProvider>().isLoggedIn) {
        // Proceed to checkout after successful login
        Navigator.pushNamed(context, '/cart');
      }
      return;
    }

    // User is logged in - proceed to checkout
    final home = context.read<Home>();
    await home.loadCart();

    if (!mounted) return;

    Navigator.pop(context); // Close cart bottom sheet
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, homeProvider, child) {
        final cartItems = homeProvider.getCartItemsLocal();
        final totalItems = cartItems.length;

        final totalPrice = cartItems.fold<double>(0, (sum, item) {
          final unitPrice = homeProvider.getFinalPrice(item.product, item.quantity);
          return sum + (unitPrice * item.quantity);
        });

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animation),
                child: child,
              ),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cart Items',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrangeColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ready for your next step?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrangeColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 48,
                                        color: AppColors.primaryOrangeColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Clear Cart?',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Are you sure you want to remove all items from your cart?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              homeProvider.clearCartAfterOrder();
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Cart cleared successfully'),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryOrangeColor,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Clear All',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.primaryOrangeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey[200]),

                // Cart Items List
                cartItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10),
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return _buildCartItem(context, item, homeProvider);
                          },
                        ),
                      ),

                // Bottom Bar with Checkout Button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Cart icon with count
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
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
                      // CHECKOUT BUTTON WITH LOGIN CHECK
                      ElevatedButton(
                        onPressed: () => _proceedToCheckout(context, cartItems),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrangeColor,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, Home homeProvider) {
    final unitPrice = homeProvider.getFinalPrice(item.product, item.quantity);
    final originalPrice = item.product.salePrice;
    final hasBulkDiscount = unitPrice < originalPrice;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.product.imagePath.isNotEmpty
                    ? Image.network(
                        item.product.imagePath,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.product.weight != null)
                      Text(
                        '${item.product.weight!.value}${item.product.weight!.unit}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (hasBulkDiscount) ...[
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '₹${unitPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: hasBulkDiscount
                                ? Colors.green.shade700
                                : Colors.black,
                          ),
                        ),
                        if (hasBulkDiscount) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Bulk',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Quantity Controls
              Column(
                children: [
                  GestureDetector(
                    onTap: () => showBulkDiscountPopup(
                      context,
                      item.product.bulkPricing,
                      item.product,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_offer_rounded,
                              size: 19, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Bulk",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // +/- Controls
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrangeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () =>
                              homeProvider.decrementQuantity(item.product.id),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            child: const Icon(Icons.remove,
                                size: 16, color: Colors.white),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 28),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              homeProvider.incrementQuantity(item.product.id),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            child: const Icon(Icons.add,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Remove button
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                homeProvider.updateQuantity(item.product.id, 0);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported_outlined,
          color: Colors.grey, size: 28),
    );
  }
}
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../Models/cart_item.dart';
// import '../../../app_colors.dart';

// void showCartBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => const CartBottomSheet(),
//   );
// }

// class CartBottomSheet extends StatefulWidget {
//   const CartBottomSheet({super.key});

//   @override
//   State<CartBottomSheet> createState() => _CartBottomSheetState();
// }

// class _CartBottomSheetState extends State<CartBottomSheet>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Home>(
//       builder: (context, homeProvider, child) {
//         // ✅ FIX 1: getCartItemsLocal() use karo, API wala nahi
//         final cartItems = homeProvider.getCartItemsLocal();
//         final totalItems = cartItems.length;

//         // ✅ FIX 2: Bulk price aware total
//         final totalPrice = cartItems.fold<double>(0, (sum, item) {
//           final unitPrice = homeProvider.getFinalPrice(item.product, item.quantity);
//           return sum + (unitPrice * item.quantity);
//         });

//         return AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return FadeTransition(
//               opacity: _animation,
//               child: SlideTransition(
//                 position: Tween<Offset>(
//                   begin: const Offset(0, 1),
//                   end: Offset.zero,
//                 ).animate(_animation),
//                 child: child,
//               ),
//             );
//           },
//           child: Container(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.7,
//             ),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24),
//                 topRight: Radius.circular(24),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 20,
//                   offset: Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Drag Handle
//                 Container(
//                   margin: const EdgeInsets.only(top: 12, bottom: 8),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Cart Items',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primaryOrangeColor,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           const Text(
//                             'Ready for your next step?',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             barrierDismissible: true,
//                             builder: (context) => AlertDialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               contentPadding: EdgeInsets.zero,
//                               content: Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   color: Colors.white,
//                                 ),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.primaryOrangeColor.withOpacity(0.1),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         Icons.shopping_cart_outlined,
//                                         size: 48,
//                                         color: AppColors.primaryOrangeColor,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 20),
//                                     const Text(
//                                       'Clear Cart?',
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     Text(
//                                       'Are you sure you want to remove all items from your cart?',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: OutlinedButton(
//                                             onPressed: () => Navigator.pop(context),
//                                             style: OutlinedButton.styleFrom(
//                                               padding: const EdgeInsets.symmetric(vertical: 14),
//                                               side: BorderSide(color: Colors.grey[300]!, width: 1.5),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                             child: const Text(
//                                               'Cancel',
//                                               style: TextStyle(
//                                                 color: Colors.black87,
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: ElevatedButton(
//                                             onPressed: () {
//                                               homeProvider.clearCartAfterOrder();
//                                               Navigator.pop(context);
//                                               Navigator.pop(context);
//                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                 SnackBar(
//                                                   content: const Text('Cart cleared successfully'),
//                                                   backgroundColor: Colors.green,
//                                                   behavior: SnackBarBehavior.floating,
//                                                   duration: const Duration(seconds: 2),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: AppColors.primaryOrangeColor,
//                                               padding: const EdgeInsets.symmetric(vertical: 14),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(12),
//                                               ),
//                                               elevation: 0,
//                                             ),
//                                             child: const Text(
//                                               'Clear All',
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           minimumSize: const Size(60, 36),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'Clear',
//                           style: TextStyle(
//                             color: AppColors.primaryOrangeColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Divider(height: 1, thickness: 1, color: Colors.grey[200]),

//                 // ✅ FIX 3: Agar cart empty hai toh message dikhao
//                 cartItems.isEmpty
//                     ? Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 40),
//                         child: Column(
//                           children: [
//                             Icon(Icons.shopping_cart_outlined,
//                                 size: 60, color: Colors.grey[300]),
//                             const SizedBox(height: 12),
//                             Text(
//                               'Your cart is empty',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[500],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Flexible(
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           padding: const EdgeInsets.all(10),
//                           itemCount: cartItems.length,
//                           separatorBuilder: (context, index) =>
//                               const SizedBox(height: 10),
//                           itemBuilder: (context, index) {
//                             final item = cartItems[index];
//                             return _buildCartItem(context, item, homeProvider);
//                           },
//                         ),
//                       ),

//                 // Bottom Bar
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border(
//                       top: BorderSide(color: Colors.grey[200]!, width: 1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       // Cart icon with count
//                       Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           Icon(
//                             Icons.shopping_cart_outlined,
//                             size: 26,
//                             color: AppColors.primaryOrangeColor,
//                           ),
//                           Positioned(
//                             right: -8,
//                             top: -8,
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryOrangeColor,
//                                 shape: BoxShape.circle,
//                               ),
//                               constraints: const BoxConstraints(
//                                 minWidth: 18,
//                                 minHeight: 18,
//                               ),
//                               child: Text(
//                                 // ✅ FIX 4: List length, puri list nahi
//                                 '$totalItems',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               '₹${totalPrice.toStringAsFixed(0)}',
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Text(
//                               '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: cartItems.isEmpty
//                             ? null
//                             : () {
//                                 Navigator.pop(context);
//                                 Navigator.pushNamed(context, '/cart');
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryOrangeColor,
//                           disabledBackgroundColor: Colors.grey,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Row(
//                           children: [
//                             Text(
//                               'Checkout',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Icon(Icons.arrow_forward, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCartItem(BuildContext context, CartItem item, Home homeProvider) {
//     // ✅ FIX 5: Bulk price per unit
//     final unitPrice = homeProvider.getFinalPrice(item.product, item.quantity);
//     final originalPrice = item.product.salePrice;
//     final hasBulkDiscount = unitPrice < originalPrice;

//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey[200]!),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // ✅ FIX 6: Image.network use karo, Image.asset nahi
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: item.product.imagePath.isNotEmpty
//                     ? Image.network(
//                         item.product.imagePath,
//                         width: 70,
//                         height: 70,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return _imagePlaceholder();
//                         },
//                       )
//                     : _imagePlaceholder(),
//               ),
//               const SizedBox(width: 12),

//               // Product Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       item.product.name,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Weight
//                     if (item.product.weight != null)
//                       Text(
//                         '${item.product.weight!.value}${item.product.weight!.unit}',
//                         style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//                       ),
//                     const SizedBox(height: 6),
//                     // Price row
//                     Row(
//                       children: [
//                         // ✅ FIX 7: Bulk price dikhao, original strikethrough
//                         if (hasBulkDiscount) ...[
//                           Text(
//                             '₹${originalPrice.toStringAsFixed(0)}',
//                             style: TextStyle(
//                               fontSize: 11,
//                               decoration: TextDecoration.lineThrough,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                         ],
//                         Text(
//                           '₹${unitPrice.toStringAsFixed(0)}',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: hasBulkDiscount
//                                 ? Colors.green.shade700
//                                 : Colors.black,
//                           ),
//                         ),
//                         if (hasBulkDiscount) ...[
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 5, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'Bulk',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.green.shade700,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),

//               // Quantity Controls
//               Column(
//                 children: [
//                   // Bulk Price button
//                   GestureDetector(
//                     onTap: () => showBulkDiscountPopup(
//                       context,
//                       item.product.bulkPricing,
//                       item.product,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.12),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(Icons.local_offer_rounded,
//                               size: 19, color: Colors.white),
//                           SizedBox(width: 4),
//                           Text(
//                             "Bulk Price",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   // +/- Controls
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryOrangeColor,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         InkWell(
//                           onTap: () =>
//                               homeProvider.decrementQuantity(item.product.id),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(8),
//                             bottomLeft: Radius.circular(8),
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(7),
//                             child: const Icon(Icons.remove,
//                                 size: 16, color: Colors.white),
//                           ),
//                         ),
//                         Container(
//                           constraints: const BoxConstraints(minWidth: 28),
//                           alignment: Alignment.center,
//                           padding:
//                               const EdgeInsets.symmetric(horizontal: 8),
//                           child: Text(
//                             '${item.quantity}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () =>
//                               homeProvider.incrementQuantity(item.product.id),
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(8),
//                             bottomRight: Radius.circular(8),
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(7),
//                             child: const Icon(Icons.add,
//                                 size: 16, color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           // Remove button
//           Positioned(
//             top: 0,
//             left: 0,
//             child: GestureDetector(
//               onTap: () {
//                 homeProvider.updateQuantity(item.product.id, 0);
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.close, size: 16, color: Colors.red),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _imagePlaceholder() {
//     return Container(
//       width: 70,
//       height: 70,
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Icon(Icons.image_not_supported_outlined,
//           color: Colors.grey, size: 28),
//     );
//   }
// }

