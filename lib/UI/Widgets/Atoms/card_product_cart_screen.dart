import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Screens/whichlist/screen/whichlist_screen.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_colors.dart';

class CartProductCard extends StatelessWidget {
  const CartProductCard({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer2<Home, WishlistProvider>(
      builder: (context, home, wishlistProvider, _) {
        final cartItems = home.getCartItemsLocal();

        if (index >= cartItems.length) return const SizedBox.shrink();

        final cartItem = cartItems[index];
        final product = cartItem.product;
        final quantity = cartItem.quantity;
        final isWishlisted = wishlistProvider.isWishlisted(product.id);
        final isThisLoading = wishlistProvider.isProductLoading(product.id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Image.network(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, color: Colors.grey, size: 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (product.weight != null)
                                Text(
                                  '${product.weight!.value}${product.weight!.unit}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              if (product.weight != null) const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrangeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  home.getCurrentTierInfo(product.id),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryOrangeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            final price = home.getFinalPrice(product, quantity);
                            final originalPrice = product.salePrice;
                            final hasBulkDiscount = price < originalPrice;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: hasBulkDiscount
                                        ? Colors.green.shade700
                                        : Colors.black,
                                  ),
                                ),
                                if (hasBulkDiscount) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '₹${originalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQtyBtn(
                            icon: Icons.remove,
                            onTap: () => home.decrementQuantity(product.id),
                            iconColor: quantity > 1
                                ? const Color(0xFF003D73)
                                : Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF003D73),
                              ),
                            ),
                          ),
                          _buildQtyBtn(
                            icon: Icons.add,
                            onTap: () => home.incrementQuantity(product.id),
                            iconColor: const Color(0xFF003D73),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: "Remove",
                      color: Colors.red.shade600,
                      onTap: () => home.removeFromCartLocal(product.id),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey.shade300,
                    ),

                    // ── Wishlist button ──────────────────────────
                    Expanded(
                      child: InkWell(
                        onTap: isThisLoading
                            ? null
                            : () async {
                                // ✅ Fix 1: product.source use karo ('admin' ya 'vendor')
                                // ✅ Fix 2: toggleWishlist ka return value lo
                                final nowWishlisted =
                                    await wishlistProvider.toggleWishlist(
                                        product.id, product.source);

                                // ✅ Fix 3: navigate sirf tab karo jab ADD hua ho
                                if (nowWishlisted && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WishlistScreen(),
                                    ),
                                  );
                                }
                              },
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isWishlisted
                                ? Colors.red.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isThisLoading)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isWishlisted
                                        ? Colors.red
                                        : Colors.grey.shade500,
                                  ),
                                )
                              else
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isWishlisted
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(isWishlisted),
                                    size: 18,
                                    color: isWishlisted
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              const SizedBox(width: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isWishlisted
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                ),
                                child: Text(
                                  isWishlisted ? 'Wishlisted ✓' : 'Wishlist',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../app_colors.dart';

// class CartProductCard extends StatelessWidget {
//   const CartProductCard({
//     super.key,
//     required this.index,
//   });

//   final int index;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Home>(
//       builder: (context, home, _) {
//         final cartItems = home.getCartItemsLocal();

//         if (index >= cartItems.length) {
//           return const SizedBox.shrink();
//         }

//         final cartItem = cartItems[index];
//         final product = cartItem.product;
//         final quantity = cartItem.quantity;

//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- Product Image Section ---
//                     Container(
//                       height: 75,
//                       width: 75,
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF9FAFB),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade100),
//                       ),
//                       child: Image.network(
//                         product.imagePath,
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) =>
//                         const Icon(Icons.image, color: Colors.grey, size: 30),
//                       ),
//                     ),
//                     const SizedBox(width: 12),

//                     // --- Details Section ---
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: Color(0xFF1F2937),
//                             ),
//                           ),
//                           const SizedBox(height: 4),

//                           // Weight & Tier Info
//                           Row(
//                             children: [
//                               if (product.weight != null)
//                                 Text(
//                                   '${product.weight!.value}${product.weight!.unit}',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               if (product.weight != null) const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primaryOrangeColor.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Text(
//                                   home.getCurrentTierInfo(product.id),
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: AppColors.primaryOrangeColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),

//                           // Price Section
//                           Builder(builder: (context) {
//                             final price = home.getFinalPrice(product, quantity);
//                             final originalPrice = product.salePrice;
//                             final hasBulkDiscount = price < originalPrice;

//                             return Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   '₹${price.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w900,
//                                     fontSize: 16,
//                                     color: hasBulkDiscount ? Colors.green.shade700 : Colors.black,
//                                   ),
//                                 ),
//                                 if (hasBulkDiscount) ...[
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     '₹${originalPrice.toStringAsFixed(0)}',
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             );
//                           }),
//                         ],
//                       ),
//                     ),

//                     // --- Quantity Control Section ---
//                     Container(
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           _buildQtyBtn(
//                             icon: Icons.remove,
//                             onTap: () => home.decrementQuantity(product.id),
//                             iconColor: quantity > 1 ? const Color(0xFF003D73) : Colors.grey,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Text(
//                               "$quantity",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Color(0xFF003D73),
//                               ),
//                             ),
//                           ),
//                           _buildQtyBtn(
//                             icon: Icons.add,
//                             onTap: () => home.incrementQuantity(product.id),
//                             iconColor: const Color(0xFF003D73),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // --- Bottom Actions Section ---
//               const Divider(height: 1, thickness: 0.5),
//               IntrinsicHeight(
//                 child: Row(
//                   children: [
//                     _buildActionButton(
//                       icon: Icons.delete_outline,
//                       label: "Remove",
//                       color: Colors.red.shade600,
//                       onTap: () => home.removeFromCartLocal(product.id),
//                     ),
//                     VerticalDivider(
//                       width: 1,
//                       thickness: 1,
//                       indent: 10,
//                       endIndent: 10,
//                       color: Colors.grey.shade300,
//                     ),
//                     _buildActionButton(
//                       icon: Icons.favorite_border_rounded, // Heart Icon change kiya
//                       label: "Wishlist", // Name change kiya
//                       color: Colors.grey.shade700,
//                       onTap: () {
//                         // Wishlist logic yahan aayega
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Helper for Quantity Buttons
//   Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap, required Color iconColor}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         width: 30,
//         alignment: Alignment.center,
//         child: Icon(icon, size: 16, color: iconColor),
//       ),
//     );
//   }

//   // Helper for Bottom Action Buttons (Remove/Save)
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 18, color: color),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: color,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }