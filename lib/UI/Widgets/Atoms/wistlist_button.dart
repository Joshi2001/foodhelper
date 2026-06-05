// widgets/wishlist_button.dart
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistButton extends StatelessWidget {
  final String productId;
  final String productType;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onToggleComplete;

  const WishlistButton({
    super.key,
    required this.productId,
    required this.productType,
    this.size = 18,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.padding,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final isWishlisted = wishlistProvider.isWishlisted(productId);
        final isLoading = wishlistProvider.isProductLoading(productId);

        return GestureDetector(
          onTap: isLoading
              ? null
              : () async {
                  final result = await wishlistProvider.toggleWishlist(
                    productId,
                    productType,
                  );
                  if (context.mounted && result) {
                    onToggleComplete?.call();
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: padding ?? const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: isLoading
                ? SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: activeColor ?? Colors.red,
                    ),
                  )
                : Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted 
                        ? (activeColor ?? Colors.red) 
                        : (inactiveColor ?? Colors.grey.shade600),
                    size: size,
                  ),
          ),
        );
      },
    );
  }
}