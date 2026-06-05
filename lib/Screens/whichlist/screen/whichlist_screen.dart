// screens/wishlist_screen.dart
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/wistlist_button.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WishlistProvider>().fetchWishlist();
      if (mounted) setState(() => _isInitialLoading = false);
    });
  }

  Future<void> _refreshWishlist() async {
    await context.read<WishlistProvider>().fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishlistProvider, Home>(
      builder: (context, wishlistProvider, home, _) {
        final ids = wishlistProvider.wishlistedProductIds.toList();
        final products = ids
            .map((id) => home.getProductByIdLocal(id))
            .whereType<Product>()
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          body: RefreshIndicator(
            onRefresh: _refreshWishlist,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 110,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (!_isInitialLoading && products.isNotEmpty)
                          Text(
                            '${products.length} item${products.length > 1 ? 's' : ''} saved',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isInitialLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrangeColor,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (products.isEmpty)
                  SliverFillRemaining(child: _EmptyWishlist())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          final quantity = home.getQuantity(product.id);
                          return _WishlistCard(
                            product: product,
                            quantity: quantity,
                            onRemove: () async {
                              await wishlistProvider.toggleWishlist(
                                product.id,
                                product.source,
                              );
                              _refreshWishlist(); // Refresh after remove
                            },
                            onAddToCart: () => home.incrementQuantity(product.id),
                            onDecrement: () => home.decrementQuantity(product.id),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Empty Wishlist Widget
class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 44,
              color: Color(0xFFEF5350),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nothing saved yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any product\nto save it here for later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrangeColor,
                    AppColors.primaryOrangeColor.withRed(220),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrangeColor.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Browse Products',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wishlist Card Widget
class _WishlistCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback onDecrement;

  const _WishlistCard({
    required this.product,
    required this.quantity,
    required this.onRemove,
    required this.onAddToCart,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final isRemoving = wishlistProvider.isProductLoading(product.id);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isRemoving ? 0.4 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFFF0F4FF),
                      child: Image.network(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.3,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Remove Button (using WishlistButton)
                            WishlistButton(
                              productId: product.id,
                              productType: product.source,
                              size: 16,
                              activeColor: const Color(0xFFEF5350),
                              backgroundColor: const Color(0xFFFFF0F0),
                              padding: const EdgeInsets.all(7),
                              onToggleComplete: onRemove,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (product.weight != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.weight!.value}${product.weight!.unit}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '₹${product.salePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Spacer(),
                            quantity == 0
                                ? GestureDetector(
                                    onTap: onAddToCart,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryOrangeColor,
                                            AppColors.primaryOrangeColor
                                                .withRed(220),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors
                                                .primaryOrangeColor
                                                .withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'ADD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryOrangeColor,
                                          AppColors.primaryOrangeColor
                                              .withRed(220),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _SmallBtn(
                                          icon: Icons.remove_rounded,
                                          onTap: onDecrement,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          child: Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        _SmallBtn(
                                          icon: Icons.add_rounded,
                                          onTap: onAddToCart,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}