
import 'dart:async';
import 'dart:convert';
import 'package:e_commerce/Models/discount_range.dart';
import 'package:e_commerce/Screens/home_screen.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:e_commerce/UI/Widgets/Atoms/wistlist_button.dart';
import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../Models/product.dart';

class ProductDetailScreenSimple extends StatefulWidget {
  final String productId;
  const ProductDetailScreenSimple({super.key, required this.productId});

  @override
  State<ProductDetailScreenSimple> createState() =>
      _ProductDetailScreenSimpleState();
}

class _ProductDetailScreenSimpleState extends State<ProductDetailScreenSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndCachePricing();
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleWishlist(String productSource) async {
    final wishlistProvider = context.read<WishlistProvider>();
    await wishlistProvider.toggleWishlist(widget.productId, productSource);
  }

  Future<void> _fetchAndCachePricing() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://grocerrybackend.onrender.com/api/public/pricing/${widget.productId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['data'] ?? [];
        final ranges = data
            .where((d) => d is Map<String, dynamic> && d['minQty'] != null)
            .map((d) => DiscountRange.fromJson(d as Map<String, dynamic>))
            .toList();
        debugPrint("✅ Pricing fetched: ${ranges.length} tiers");
        if (mounted)
          context.read<Home>().cacheBulkRanges(widget.productId, ranges);
      }
    } catch (e) {
      debugPrint("❌ _fetchAndCachePricing: $e");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Home, WishlistProvider>(
      builder: (context, home, wishlistProvider, _) {
        final product = home.getProductByIdLocal(widget.productId);
        if (product == null) {
          return const Scaffold(
              body: Center(child: Text('Product not found')));
        }
        final quantity = home.getQuantity(product.id);
        final cachedRanges = home.getCachedBulkRanges(product.id) ??
            (product.bulkPricing.isNotEmpty ? product.bulkPricing : null);

        final isWishlisted = wishlistProvider.isWishlisted(widget.productId);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                actions: [
                   WishlistButton(
                     productId: product.id,
                     productType: product.source,
                     size: 18,
                   ),
                   SizedBox(width: 10,),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: const Icon(Icons.home_outlined, color: Colors.black),
                  ),
                  const SizedBox(width: 15),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: SafeArea(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _ProductImageGallery(
                            imagePaths: [
                              product.imagePath,
                              ...product.galleryImages,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "${product.category?.name ?? 'Products'} > ${product.subcategory?.name ?? ''} > ${product.subSubcategory?.name ?? ''}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _PriceBlock(
                        salePrice: product.salePrice,
                        mrp: product.mrp,
                        quantity: quantity,
                        ranges: cachedRanges,
                        weight: product.weight,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow("Brand", product.brand ?? "N/A"),
                      _buildInfoRow("Item Code", product.id.substring(0, 8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoRow("Unit", product.weight != null
                              ? "${product.weight!.value}${product.weight!.unit}"
                              : "900 gm"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    showBulkDiscountPopup(
                                        context, product.bulkPricing, product),
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    border: Border.all(
                                        color: Colors.green, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Bulk Pricing",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: quantity == 0
                                    ? OutlinedButton(
                                  onPressed: () =>
                                      home.incrementQuantity(product.id),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: AppColors.primaryOrangeColor),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10)),
                                  ),
                                  child: Text(
                                    "Add",
                                    style: TextStyle(
                                      color: AppColors.primaryOrangeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                                    : _QuantityStepper(
                                  quantity: quantity,
                                  onDecrement: () =>
                                      home.decrementQuantity(product.id),
                                  onIncrement: () =>
                                      home.incrementQuantity(product.id),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSimilarProductsSection(home, product),
                      const SizedBox(height: 20),
                      _WishlistBanner(
                        isWishlisted: isWishlisted,
                        onTap: () => _toggleWishlist(product.source),
                        isLoading: wishlistProvider.isProductLoading(
                            product.id),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomStickyContainer(),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontSize: 15, color: Colors.black87))
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: label == "Brand"
                  ? TextDecoration.underline
                  : TextDecoration.none,
              color: label == "Brand" ? const Color(0xFF1A3D7C) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProductsSection(Home homeProvider, var currentProduct) {
    final similar = homeProvider.products
        .where((p) => p.id != currentProduct.id)
        .take(20)
        .toList();

    if (similar.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('You might also like',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ],
                ),
                Text('${similar.length} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: similar.length,
              itemBuilder: (context, index) {
                final product = similar[index];
                return _SimilarProductCard(
                  product: product,
                  onAddedToCart: () {
                    _showSnack('${product.name} added to cart!',
                        AppColors.primaryOrangeColor);
                    setState(() {});
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          const Text("Product Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(currentProduct.description ?? "No description available",
              style: const TextStyle(color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }
}

class _SimilarProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddedToCart;

  const _SimilarProductCard({
    required this.product,
    required this.onAddedToCart,
  });

  @override
  State<_SimilarProductCard> createState() => _SimilarProductCardState();
}

class _SimilarProductCardState extends State<_SimilarProductCard> {
  bool _loading = false;

  int _getQty(Home provider) => provider.getQuantity(widget.product.id);

  Future<void> _addToCart(Home provider) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      provider.updateQuantity(widget.product.id, 1);
      await provider.addToCart(widget.product.id, 1);
      widget.onAddedToCart();
    } catch (e) {
      debugPrint('❌ addToCart error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _increment(Home provider) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final newQty = _getQty(provider) + 1;
      provider.updateQuantity(widget.product.id, newQty);
      await provider.addToCart(widget.product.id, newQty);
    } catch (e) {
      debugPrint('❌ increment error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decrement(Home provider) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final currentQty = _getQty(provider);
      if (currentQty <= 1) {
        provider.updateQuantity(widget.product.id, 0);
        await provider.removeFromCart(widget.product.id);
      } else {
        final newQty = currentQty - 1;
        provider.updateQuantity(widget.product.id, newQty);
        await provider.addToCart(widget.product.id, newQty);
      }
    } catch (e) {
      debugPrint('❌ decrement error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToProductDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreenSimple(
          productId: widget.product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.product.basePrice;
    final double salePrice = widget.product.salePrice;
    final double mrp = widget.product.mrp;
    final bool hasDiscount = mrp > 0 && mrp > salePrice;
    final double displayPrice = salePrice > 0 ? salePrice : basePrice;

    return Consumer<Home>(
      builder: (context, homeProvider, _) {
        final int qty = _getQty(homeProvider);

        return GestureDetector(
          onTap: _navigateToProductDetail,
          child: Container(
            width: 155,
            margin: const EdgeInsets.only(right: 14, bottom: 5, top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Stack(
                    children: [
                      Container(
                        height: 94,
                        width: double.infinity,
                        color: const Color(0xFFF8F9FB),
                        padding: const EdgeInsets.all(10),
                        child: widget.product.imagePath.isNotEmpty
                            ? Image.network(
                          widget.product.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                            : _imagePlaceholder(),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                            ),
                            child: Text(
                              '${widget.product.discountPercentage.toInt()}% OFF',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.weight != null)
                        Text(
                          '${widget.product.weight!.value}${widget.product.weight!.unit}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasDiscount)
                                  Text(
                                    '₹${mrp.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade400,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                Text(
                                  '₹${displayPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 65,
                            height: 32,
                            child: _loading
                                ? const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryOrangeColor,
                                    ),
                                  ),
                                )
                                : qty == 0
                                ? OutlinedButton(
                              onPressed: () => _addToCart(homeProvider),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF003D73),
                                    fontWeight: FontWeight.w800),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF003D73),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _decrement(homeProvider),
                                      child: const Icon(Icons.remove,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _increment(homeProvider),
                                      child: const Icon(Icons.add,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
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
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 32),
      ),
    );
  }
}
class _ProductImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  const _ProductImageGallery({required this.imagePaths});

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    final uniqueImages = widget.imagePaths.toSet().toList();
    if (uniqueImages.length > 1) {
      _startAutoSlider(uniqueImages.length);
    }
  }

  void _startAutoSlider(int totalImages) {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          if (_currentPage < totalImages - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayImages = widget.imagePaths.toSet().toList();

    if (displayImages.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 50));
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: displayImages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.network(
                    displayImages[index],
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A3D7C)
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_rounded,
                        size: 60,
                        color: Colors.grey
                    ),
                  ),
                ),
              );
            },
          ),
          if (displayImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  displayImages.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF1A3D7C)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QuantityStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove, color: Colors.white, size: 16), padding: EdgeInsets.zero),
          Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(onPressed: onIncrement, icon: const Icon(Icons.add, color: Colors.white, size: 16), padding: EdgeInsets.zero),
        ],
      ),
    );
  }
}

class _WishlistBanner extends StatelessWidget {
  final bool isWishlisted;
  final bool isLoading;
  final VoidCallback onTap;

  const _WishlistBanner({
    required this.isWishlisted,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isWishlisted ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isWishlisted ? 'Saved to wishlist' : 'Add to wishlist',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isWishlisted ? Colors.red : Colors.black87,
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
              )
          ],
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final double salePrice;
  final double mrp;
  final int quantity;
  final List<dynamic>? ranges;
  final Weight? weight;

  const _PriceBlock({
    required this.salePrice,
    required this.mrp,
    required this.quantity,
    required this.ranges,
    this.weight,
  });

  dynamic _getActiveRange(List<dynamic>? ranges, int quantity) {
  if (ranges == null || ranges.isEmpty || quantity == 0) return null;
  for (final range in ranges) {
    if (quantity >= range.min && (range.max == -1 || quantity <= range.max)) {
      return range;
    }
  }
  return null;
}

  double get discountPercentage {
    if (mrp <= 0 || salePrice <= 0) return 0;
    final discountAmount = mrp - salePrice;
    if (discountAmount <= 0) return 0;
    return (discountAmount / mrp) * 100;
  }

  double get pricePerGram {
    if (weight == null) return salePrice / 100;
    if (weight!.unit == 'kg') {
      final weightInGrams = weight!.value * 1000;
      return salePrice / weightInGrams;
    } else if (weight!.unit == 'gm') {
      return salePrice / weight!.value;
    } else if (weight!.unit == 'pcs') {
      return salePrice / 100; // Default for pieces
    }
    return salePrice / 100;
  }

  @override
  Widget build(BuildContext context) {
    final activeRange = _getActiveRange(ranges, quantity);
    final double unitPrice = (activeRange != null && activeRange.price > 0) 
        ? activeRange.price.toDouble() 
        : salePrice;
    final double displayPrice = quantity == 0 ? unitPrice : unitPrice * quantity;
    final discountPercent = discountPercentage;
    final hasValidMrp = mrp > 0 && mrp > salePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '₹${displayPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(width: 10),
            if (hasValidMrp) ...[
              Text(
                '₹${mrp.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3D7C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${discountPercent.toStringAsFixed(0)}% off",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "₹${pricePerGram.toStringAsFixed(2)}/${weight?.unit == 'kg' ? 'gm' : (weight?.unit ?? 'gm')}",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

// import 'dart:convert';
// import 'package:e_commerce/Models/discount_range.dart';
// import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
// import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
//
// class ProductDetailScreenSimple extends StatefulWidget {
//   final String productId;
//   const ProductDetailScreenSimple({super.key, required this.productId});
//
//   @override
//   State<ProductDetailScreenSimple> createState() =>
//       _ProductDetailScreenSimpleState();
// }
//
// class _ProductDetailScreenSimpleState extends State<ProductDetailScreenSimple>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAndCachePricing();
//     });
//   }
//
//   Future<void> _toggleWishlist(String productSource) async {
//     final wishlistProvider = context.read<WishlistProvider>();
//     // Pass both productId and source to ensure product field is not null
//     await wishlistProvider.toggleWishlist(widget.productId, productSource);
//   }
//
//   Future<void> _fetchAndCachePricing() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://grocerrybackend.onrender.com/api/public/pricing/${widget.productId}'),
//         headers: {'Content-Type': 'application/json'},
//       );
//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body) as Map<String, dynamic>;
//         final List<dynamic> data = body['data'] ?? [];
//         final ranges = data
//             .where((d) => d is Map<String, dynamic> && d['minQty'] != null)
//             .map((d) => DiscountRange.fromJson(d as Map<String, dynamic>))
//             .toList();
//         debugPrint("✅ Pricing fetched: ${ranges.length} tiers");
//         if (mounted)
//           context.read<Home>().cacheBulkRanges(widget.productId, ranges);
//       }
//     } catch (e) {
//       debugPrint("❌ _fetchAndCachePricing: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<Home, WishlistProvider>(
//       builder: (context, home, wishlistProvider, _) {
//         final product = home.getProductByIdLocal(widget.productId);
//         if (product == null) {
//           return const Scaffold(
//               body: Center(child: Text('Product not found')));
//         }
//         final quantity = home.getQuantity(product.id);
//         final cachedRanges = home.getCachedBulkRanges(product.id) ??
//             (product.bulkPricing.isNotEmpty ? product.bulkPricing : null);
//
//         final isWishlisted = wishlistProvider.isWishlisted(widget.productId);
//
//         return Scaffold(
//           backgroundColor: const Color(0xFFF7F8FA),
//           body: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 320,
//                 pinned: true,
//                 backgroundColor: Colors.white,
//                 elevation: 0,
//                 surfaceTintColor: Colors.transparent,
//                 leading: _CircleIconButton(
//                   icon: Icons.arrow_back_ios_new_rounded,
//                   onTap: () => Navigator.pop(context),
//                 ),
//                 actions: [
//                   _CircleIconButton(
//                     icon: Icons.ios_share_rounded,
//                     onTap: () {},
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: _ProductImageHero(imagePath: product.imagePath),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: FadeTransition(
//                   opacity: _fadeAnim,
//                   child: SlideTransition(
//                     position: _slideAnim,
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(children: [
//                             _Badge(
//                               label: 'Bulk Offers',
//                               icon: Icons.local_offer_rounded,
//                               bgColor: const Color(0xFFE8F5E9),
//                               textColor: const Color(0xFF2E7D32),
//                             ),
//                             const SizedBox(width: 8),
//                             _Badge(
//                               label: 'Fast Delivery',
//                               icon: Icons.bolt_rounded,
//                               bgColor: const Color(0xFFFFF3E0),
//                               textColor: const Color(0xFFE65100),
//                             ),
//                           ]),
//                           const SizedBox(height: 14),
//                           Text(
//                             product.name,
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.w800,
//                               color: Color(0xFF1A1A2E),
//                               letterSpacing: -0.5,
//                               height: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 5),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                               border:
//                                   Border.all(color: const Color(0xFFE0E0E0)),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.04),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 )
//                               ],
//                             ),
//                             child: Text(
//                               product.weight != null
//                                   ? "${product.weight!.value}${product.weight!.unit}"
//                                   : "N/A",
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF757575),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _PriceBlock(
//                             salePrice: product.salePrice,
//                             quantity: quantity,
//                             ranges: cachedRanges,
//                           ),
//                           const SizedBox(height: 20),
//                           Row(children: [
//                             OutlinedButton.icon(
//                               onPressed: () => showBulkDiscountPopup(
//                                   context, product.bulkPricing, product),
//                               icon: const Icon(Icons.local_offer_rounded,
//                                   size: 16, color: Color(0xFF2E7D32)),
//                               label: const Text(
//                                 'Bulk Price',
//                                 style: TextStyle(
//                                   color: Color(0xFF2E7D32),
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               style: OutlinedButton.styleFrom(
//                                 side: const BorderSide(
//                                     color: Color(0xFF2E7D32), width: 1.5),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12)),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 14, vertical: 12),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: quantity == 0
//                                   ? _AddButton(
//                                       onTap: () =>
//                                           home.incrementQuantity(product.id))
//                                   : _QuantityStepper(
//                                       quantity: quantity,
//                                       onDecrement: () =>
//                                           home.decrementQuantity(product.id),
//                                       onIncrement: () =>
//                                           home.incrementQuantity(product.id),
//                                     ),
//                             ),
//                           ]),
//                           const SizedBox(height: 16),
//                           _CartBanner(quantity: quantity),
//                           const SizedBox(height: 28),
//                           _WishlistBanner(
//                             isWishlisted: isWishlisted,
//                             onTap: () => _toggleWishlist(product.source),
//                             isLoading:
//                                 wishlistProvider.isProductLoading(product.id),
//                           ),
//                           const SizedBox(height: 16),
//                           _SectionCard(
//                             title: 'About This Product',
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'High-quality ${product.name} perfect for daily use. Carefully sourced and packed to ensure freshness and quality. Ideal for bulk purchases with attractive discounts on larger quantities.',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey[700],
//                                       height: 1.7),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 const _FeatureItem(
//                                   label: '100% Authentic Product',
//                                   icon: Icons.verified_rounded,
//                                   color: Color(0xFF1565C0),
//                                 ),
//                                 const _FeatureItem(
//                                   label: 'Fast Delivery Available',
//                                   icon: Icons.local_shipping_rounded,
//                                   color: Color(0xFF6A1B9A),
//                                 ),
//                                 const _FeatureItem(
//                                   label: 'Easy Returns & Refunds',
//                                   icon: Icons.assignment_return_rounded,
//                                   color: Color(0xFF00796B),
//                                 ),
//                                 const _FeatureItem(
//                                   label: 'Bulk Discounts Available',
//                                   icon: Icons.card_giftcard_rounded,
//                                   color: Color(0xFFE65100),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 100),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: const BottomStickyContainer(),
//         );
//       },
//     );
//   }
// }
//
// class _WishlistButton extends StatelessWidget {
//   final bool isWishlisted;
//   final bool isLoading;
//   final VoidCallback onTap;
//
//   const _WishlistButton({
//     required this.isWishlisted,
//     required this.isLoading,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: isWishlisted ? const Color(0xFFFFF0F0) : Colors.white,
//           shape: BoxShape.circle,
//           border: isWishlisted
//               ? Border.all(color: Colors.red.withOpacity(0.25), width: 1.5)
//               : null,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: isLoading
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 )
//               : AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 250),
//                   transitionBuilder: (child, anim) =>
//                       ScaleTransition(scale: anim, child: child),
//                   child: Icon(
//                     isWishlisted
//                         ? Icons.favorite_rounded
//                         : Icons.favorite_border_rounded,
//                     key: ValueKey(isWishlisted),
//                     size: 18,
//                     color:
//                         isWishlisted ? Colors.red : const Color(0xFF1A1A2E),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
//
// class _WishlistBanner extends StatelessWidget {
//   final bool isWishlisted;
//   final bool isLoading;
//   final VoidCallback onTap;
//
//   const _WishlistBanner({
//     required this.isWishlisted,
//     required this.isLoading,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isWishlisted
//               ? const Color(0xFFFFF0F0)
//               : const Color(0xFFFFF8F0),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isWishlisted
//                 ? const Color(0xFFFFCDD2)
//                 : const Color(0xFFFFE0B2),
//           ),
//         ),
//         child: Row(
//           children: [
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 250),
//               child: Icon(
//                 isWishlisted
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 key: ValueKey(isWishlisted),
//                 color:
//                     isWishlisted ? Colors.red : AppColors.primaryOrangeColor,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 isWishlisted
//                     ? 'Saved to your wishlist!'
//                     : 'Save this product to your wishlist',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: isWishlisted
//                       ? const Color(0xFFC62828)
//                       : const Color(0xFFBF360C),
//                 ),
//               ),
//             ),
//             if (isLoading)
//               const SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2, color: Colors.grey),
//               )
//             else
//               Text(
//                 isWishlisted ? 'Remove' : 'Save',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: isWishlisted
//                       ? Colors.red
//                       : AppColors.primaryOrangeColor,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// DiscountRange? _getActiveRange(List<DiscountRange>? ranges, int quantity) {
//   if (ranges == null || ranges.isEmpty || quantity == 0) return null;
//   for (final range in ranges) {
//     if (range.isQuantityInRange(quantity)) return range;
//   }
//   return null;
// }
//
// class _PriceBlock extends StatelessWidget {
//   final double salePrice;
//   final int quantity;
//   final List<DiscountRange>? ranges;
//
//   const _PriceBlock({
//     required this.salePrice,
//     required this.quantity,
//     required this.ranges,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final activeRange = _getActiveRange(ranges, quantity);
//     final double unitPrice =
//         (activeRange != null && activeRange.price > 0)
//             ? activeRange.price
//             : salePrice;
//     final double displayPrice =
//         quantity == 0 ? unitPrice : unitPrice * quantity;
//     final int discountPct = (activeRange != null &&
//             activeRange.price > 0 &&
//             salePrice > activeRange.price)
//         ? ((salePrice - activeRange.price) / salePrice * 100).round()
//         : 0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   quantity > 1
//                       ? '₹${salePrice.toStringAsFixed(0)} × $quantity'
//                       : '₹${salePrice.toStringAsFixed(0)}',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[500],
//                     decoration: TextDecoration.lineThrough,
//                     decorationColor: Colors.grey[400],
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '₹${displayPrice.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF1A1A2E),
//                     letterSpacing: -1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 12),
//             if (discountPct > 0)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFF5252),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '$discountPct% OFF',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         if (activeRange != null) ...[
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5E9),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.local_offer_rounded,
//                     size: 13, color: Color(0xFF2E7D32)),
//                 const SizedBox(width: 5),
//                 Text(
//                   '₹${unitPrice.toStringAsFixed(0)}/unit · ${activeRange.rangeText} · Bulk deal applied!',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF2E7D32),
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }
//
// class _ProductImageHero extends StatelessWidget {
//   final String imagePath;
//   const _ProductImageHero({required this.imagePath});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Positioned(
//             top: -40,
//             right: -40,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.primaryOrangeColor.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -20,
//             left: -30,
//             child: Container(
//               width: 130,
//               height: 130,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.green.withOpacity(0.07),
//               ),
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                   top: 80, bottom: 20, left: 32, right: 32),
//               child: Image.network(
//                 imagePath,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) => const Icon(
//                   Icons.image_not_supported_rounded,
//                   size: 64,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _CircleIconButton({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             )
//           ],
//         ),
//         child: Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
//       ),
//     );
//   }
// }
//
// class _Badge extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color bgColor;
//   final Color textColor;
//   const _Badge(
//       {required this.label,
//       required this.icon,
//       required this.bgColor,
//       required this.textColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//           color: bgColor, borderRadius: BorderRadius.circular(20)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: textColor),
//           const SizedBox(width: 5),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: textColor,
//                   letterSpacing: 0.2)),
//         ],
//       ),
//     );
//   }
// }
//
// class _AddButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _AddButton({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppColors.primaryOrangeColor,
//               AppColors.primaryOrangeColor.withRed(220)
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primaryOrangeColor.withOpacity(0.4),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             )
//           ],
//         ),
//         child: const Center(
//           child: Text(
//             'ADD TO CART',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w800,
//               fontSize: 13,
//               letterSpacing: 1,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _QuantityStepper extends StatelessWidget {
//   final int quantity;
//   final VoidCallback onDecrement;
//   final VoidCallback onIncrement;
//   const _QuantityStepper(
//       {required this.quantity,
//       required this.onDecrement,
//       required this.onIncrement});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primaryOrangeColor,
//             AppColors.primaryOrangeColor.withRed(220)
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryOrangeColor.withOpacity(0.4),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _StepperBtn(icon: Icons.remove_rounded, onTap: onDecrement),
//           Text(
//             '$quantity',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w900,
//               fontSize: 18,
//             ),
//           ),
//           _StepperBtn(icon: Icons.add_rounded, onTap: onIncrement),
//         ],
//       ),
//     );
//   }
// }
//
// class _StepperBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _StepperBtn({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 32,
//         height: 32,
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }
// }
//
// class _CartBanner extends StatelessWidget {
//   final int quantity;
//   const _CartBanner({required this.quantity});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//             colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)]),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFA5D6A7)),
//       ),
//       child: Row(children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: const BoxDecoration(
//               color: Color(0xFF2E7D32), shape: BoxShape.circle),
//           child: const Icon(Icons.shopping_bag_rounded,
//               color: Colors.white, size: 16),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           quantity == 0
//               ? 'Your cart is empty'
//               : '$quantity item${quantity > 1 ? 's' : ''} added to cart',
//           style: const TextStyle(
//             color: Color(0xFF2E7D32),
//             fontWeight: FontWeight.w700,
//             fontSize: 14,
//           ),
//         ),
//         const Spacer(),
//         if (quantity > 0)
//           const Icon(Icons.check_circle_rounded,
//               color: Color(0xFF2E7D32), size: 18),
//       ]),
//     );
//   }
// }
//
// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _SectionCard({required this.title, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w800,
//                 color: Color(0xFF1A1A2E),
//                 letterSpacing: -0.3,
//               ),
//             ),
//             const SizedBox(height: 14),
//             child,
//           ]),
//     );
//   }
// }
//
// class _FeatureItem extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _FeatureItem(
//       {required this.label, required this.icon, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 18),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1A1A2E),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// // import 'dart:convert';
// // import 'package:e_commerce/Models/discount_range.dart';
// // import 'package:e_commerce/Services/Providers/product_provider.dart';
// // import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
// // import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
// // import 'package:e_commerce/app_colors.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:provider/provider.dart';
//
// // class ProductDetailScreenSimple extends StatefulWidget {
// //   final String productId;
// //   const ProductDetailScreenSimple({super.key, required this.productId});
//
// //   @override
// //   State<ProductDetailScreenSimple> createState() =>
// //       _ProductDetailScreenSimpleState();
// // }
//
// // class _ProductDetailScreenSimpleState extends State<ProductDetailScreenSimple>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _animController;
// //   late Animation<double> _fadeAnim;
// //   late Animation<Offset> _slideAnim;
//
// //   @override
// //   void initState() {
// //     super.initState();
// //     _animController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 500),
// //     );
// //     _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
// //     _slideAnim = Tween<Offset>(
// //       begin: const Offset(0, 0.08),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
// //     _animController.forward();
//
// //     WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAndCachePricing());
// //   }
//
// //   Future<void> _fetchAndCachePricing() async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('https://grocerrybackend.onrender.com/api/public/pricing/${widget.productId}'),
// //         headers: {'Content-Type': 'application/json'},
// //       );
// //       if (response.statusCode == 200) {
// //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// //         final List<dynamic> data = body['data'] ?? [];
// //         final ranges = data
// //             .where((d) => d is Map<String, dynamic> && d['minQty'] != null)
// //             .map((d) => DiscountRange.fromJson(d as Map<String, dynamic>))
// //             .toList();
// //         debugPrint("✅ Pricing fetched: ${ranges.length} tiers");
// //         if (mounted) context.read<Home>().cacheBulkRanges(widget.productId, ranges);
// //       }
// //     } catch (e) {
// //       debugPrint("❌ _fetchAndCachePricing: $e");
// //     }
// //   }
//
// //   @override
// //   void dispose() {
// //     _animController.dispose();
// //     super.dispose();
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<Home>(
// //       builder: (context, home, _) {
// //         final product = home.getProductByIdLocal(widget.productId);
// //         if (product == null) {
// //           return const Scaffold(body: Center(child: Text('Product not found')));
// //         }
// //         final quantity = home.getQuantity(product.id);
//
// //         final cachedRanges = home.getCachedBulkRanges(product.id) ??
// //             (product.bulkPricing.isNotEmpty ? product.bulkPricing : null);
//
// //         return Scaffold(
// //           backgroundColor: const Color(0xFFF7F8FA),
// //           body: CustomScrollView(
// //               slivers: [
// //                 SliverAppBar(
// //                   expandedHeight: 320,
// //                   pinned: true,
// //                   backgroundColor: Colors.white,
// //                   elevation: 0,
// //                   leading: _CircleIconButton(
// //                     icon: Icons.arrow_back_ios_new_rounded,
// //                     onTap: () => Navigator.pop(context),
// //                   ),
// //                   actions: [
// //                     _CircleIconButton(
// //                       icon: Icons.ios_share_rounded,
// //                       onTap: () {},
// //                     ),
// //                     const SizedBox(width: 4),
// //                     // Updated wishlist button with loading state and animation
// //                     // _WishlistButton(
// //                     //   isWishlisted: _isWishlisted,
// //                     //   isLoading: wishlistProvider.isLoading,
// //                     //   onTap: _toggleWishlist,
// //                     // ),
// //                     const SizedBox(width: 8),
// //                   ],
// //                   flexibleSpace: FlexibleSpaceBar(
// //                     background: _ProductImageHero(imagePath: product.imagePath),
// //                   ),
// //                 ),
// //               SliverToBoxAdapter(
// //                 child: FadeTransition(
// //                   opacity: _fadeAnim,
// //                   child: SlideTransition(
// //                     position: _slideAnim,
// //                     child: Padding(
// //                       padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           // Badges
// //                           Row(children: [
// //                             _Badge(label: 'Bulk Offers', icon: Icons.local_offer_rounded, bgColor: const Color(0xFFE8F5E9), textColor: const Color(0xFF2E7D32)),
// //                             const SizedBox(width: 8),
// //                             _Badge(label: 'Fast Delivery', icon: Icons.bolt_rounded, bgColor: const Color(0xFFFFF3E0), textColor: const Color(0xFFE65100)),
// //                           ]),
// //                           const SizedBox(height: 14),
// //                           // Name
// //                           Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.5, height: 1.2)),
// //                           const SizedBox(height: 10),
// //                           // Weight pill
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(20),
// //                               border: Border.all(color: const Color(0xFFE0E0E0)),
// //                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
// //                             ),
// //                             child: Text(
// //                               product.weight != null ? "${product.weight!.value}${product.weight!.unit}" : "N/A",
// //                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 16),
// //                           // Price block — uses DiscountRange list from cache
// //                           _PriceBlock(
// //                             salePrice: product.salePrice,
// //                             quantity: quantity,
// //                             ranges: cachedRanges,
// //                           ),
// //                           const SizedBox(height: 20),
// //                           // Actions
// //                           Row(children: [
// //                             OutlinedButton.icon(
// //                               onPressed: () => showBulkDiscountPopup(context, product.bulkPricing, product),
// //                               icon: const Icon(Icons.local_offer_rounded, size: 16, color: Color(0xFF2E7D32)),
// //                               label: const Text('Bulk Price', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 13)),
// //                               style: OutlinedButton.styleFrom(
// //                                 side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
// //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: quantity == 0
// //                                   ? _AddButton(onTap: () => home.incrementQuantity(product.id))
// //                                   : _QuantityStepper(
// //                                       quantity: quantity,
// //                                       onDecrement: () => home.decrementQuantity(product.id),
// //                                       onIncrement: () => home.incrementQuantity(product.id),
// //                                     ),
// //                             ),
// //                           ]),
// //                           const SizedBox(height: 16),
// //                           _CartBanner(quantity: quantity),
// //                           const SizedBox(height: 28),
// //                           _SectionCard(
// //                             title: 'About This Product',
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'High-quality ${product.name} perfect for daily use. Carefully sourced and packed to ensure freshness and quality. Ideal for bulk purchases with attractive discounts on larger quantities.',
// //                                   style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.7),
// //                                 ),
// //                                 const SizedBox(height: 20),
// //                                 const _FeatureItem(label: '100% Authentic Product', icon: Icons.verified_rounded, color: Color(0xFF1565C0)),
// //                                 const _FeatureItem(label: 'Fast Delivery Available', icon: Icons.local_shipping_rounded, color: Color(0xFF6A1B9A)),
// //                                 const _FeatureItem(label: 'Easy Returns & Refunds', icon: Icons.assignment_return_rounded, color: Color(0xFF00796B)),
// //                                 const _FeatureItem(label: 'Bulk Discounts Available', icon: Icons.card_giftcard_rounded, color: Color(0xFFE65100)),
// //                               ],
// //                             ),
// //                           ),
// //                           const SizedBox(height: 100),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           bottomNavigationBar: const BottomStickyContainer(),
// //         );
// //       },
// //     );
// //   }
// // }
// // class _WishlistButton extends StatelessWidget {
// //   final bool isWishlisted;
// //   final bool isLoading;
// //   final VoidCallback onTap;
//
// //   const _WishlistButton({
// //     required this.isWishlisted,
// //     required this.isLoading,
// //     required this.onTap,
// //   });
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: isLoading ? null : onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
// //         width: 38,
// //         height: 38,
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           shape: BoxShape.circle,
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.08),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: isLoading
// //             ? const SizedBox(
// //                 width: 18,
// //                 height: 18,
// //                 child: CircularProgressIndicator(
// //                   strokeWidth: 2,
// //                   color: Color(0xFF1A1A2E),
// //                 ),
// //               )
// //             : AnimatedSwitcher(
// //                 duration: const Duration(milliseconds: 200),
// //                 child: Icon(
// //                   isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
// //                   key: ValueKey(isWishlisted),
// //                   size: 18,
// //                   color: isWishlisted ? Colors.red : const Color(0xFF1A1A2E),
// //                 ),
// //               ),
// //       ),
// //     );
// //   }
// // }
// // DiscountRange? _getActiveRange(List<DiscountRange>? ranges, int quantity) {
// //   if (ranges == null || ranges.isEmpty || quantity == 0) return null;
// //   for (final range in ranges) {
// //     if (range.isQuantityInRange(quantity)) return range;
// //   }
// //   return null;
// // }
//
// // class _PriceBlock extends StatelessWidget {
// //   final double salePrice;
// //   final int quantity;
// //   final List<DiscountRange>? ranges;
//
// //   const _PriceBlock({
// //     required this.salePrice,
// //     required this.quantity,
// //     required this.ranges,
// //   });
//
// //   @override
// //   Widget build(BuildContext context) {
// //     final activeRange = _getActiveRange(ranges, quantity);
//
// //     final double unitPrice =
// //         (activeRange != null && activeRange.price > 0)
// //             ? activeRange.price
// //             : salePrice;
//
// //     final double displayPrice = quantity == 0 ? unitPrice : unitPrice * quantity;
//
// //     final int discountPct =
// //         (activeRange != null && activeRange.price > 0 && salePrice > activeRange.price)
// //             ? ((salePrice - activeRange.price) / salePrice * 100).round()
// //             : 0;
//
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   quantity > 1
// //                       ? '₹${salePrice.toStringAsFixed(0)} × $quantity'
// //                       : '₹${salePrice.toStringAsFixed(0)}',
// //                   style: TextStyle(
// //                     fontSize: 13,
// //                     color: Colors.grey[500],
// //                     decoration: TextDecoration.lineThrough,
// //                     decorationColor: Colors.grey[400],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   '₹${displayPrice.toStringAsFixed(0)}',
// //                   style: const TextStyle(
// //                     fontSize: 32,
// //                     fontWeight: FontWeight.w900,
// //                     color: Color(0xFF1A1A2E),
// //                     letterSpacing: -1,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(width: 12),
// //             if (discountPct > 0)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFFF5252),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Text(
// //                   '$discountPct% OFF',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w800,
// //                     letterSpacing: 0.5,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         if (activeRange != null) ...[
// //           const SizedBox(height: 8),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFE8F5E9),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Icon(Icons.local_offer_rounded, size: 13, color: Color(0xFF2E7D32)),
// //                 const SizedBox(width: 5),
// //                 Text(
// //                   '₹${unitPrice.toStringAsFixed(0)}/unit · ${activeRange.rangeText} · Bulk deal applied!',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF2E7D32),
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// // }
//
// // class _ProductImageHero extends StatelessWidget {
// //   final String imagePath;
// //   const _ProductImageHero({required this.imagePath});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //             colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight
// //         ),
// //       ),
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           Positioned(
// //               top: -40,
// //               right: -40,
// //               child: Container(
// //                   width: 200,
// //                   height: 200,
// //                   decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: AppColors.primaryOrangeColor.withOpacity(0.06)
// //                   )
// //               )
// //           ),
// //           Positioned(
// //               bottom: -20,
// //               left: -30,
// //               child: Container(
// //                   width: 130,
// //                   height: 130,
// //                   decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.green.withOpacity(0.07)
// //                   )
// //               )
// //           ),
// //           Center(
// //             child: Padding(
// //               padding: const EdgeInsets.only(top: 80, bottom: 20, left: 32, right: 32),
// //               child: Image.network(
// //                 imagePath,
// //                 fit: BoxFit.contain,
// //                 alignment: Alignment.center,
// //                 errorBuilder: (_, __, ___) => const Icon(
// //                     Icons.image_not_supported_rounded,
// //                     size: 64,
// //                     color: Colors.grey
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // class _CircleIconButton extends StatelessWidget {
// //   final IconData icon;
// //   final VoidCallback onTap;
// //   const _CircleIconButton({required this.icon, required this.onTap});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
// //         width: 38, height: 38,
// //         decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
// //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
// //         child: Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
// //       ),
// //     );
// //   }
// // }
//
// // class _Badge extends StatelessWidget {
// //   final String label; final IconData icon; final Color bgColor; final Color textColor;
// //   const _Badge({required this.label, required this.icon, required this.bgColor, required this.textColor});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
// //       child: Row(mainAxisSize: MainAxisSize.min, children: [
// //         Icon(icon, size: 13, color: textColor), const SizedBox(width: 5),
// //         Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.2)),
// //       ]),
// //     );
// //   }
// // }
//
// // class _AddButton extends StatelessWidget {
// //   final VoidCallback onTap;
// //   const _AddButton({required this.onTap});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         height: 48,
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(colors: [AppColors.primaryOrangeColor, AppColors.primaryOrangeColor.withRed(220)], begin: Alignment.topLeft, end: Alignment.bottomRight),
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [BoxShadow(color: AppColors.primaryOrangeColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
// //         ),
// //         child: const Center(child: Text('ADD TO CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1))),
// //       ),
// //     );
// //   }
// // }
//
// // class _QuantityStepper extends StatelessWidget {
// //   final int quantity; final VoidCallback onDecrement; final VoidCallback onIncrement;
// //   const _QuantityStepper({required this.quantity, required this.onDecrement, required this.onIncrement});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 48,
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(colors: [AppColors.primaryOrangeColor, AppColors.primaryOrangeColor.withRed(220)], begin: Alignment.topLeft, end: Alignment.bottomRight),
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [BoxShadow(color: AppColors.primaryOrangeColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: [
// //           _StepperBtn(icon: Icons.remove_rounded, onTap: onDecrement),
// //           Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
// //           _StepperBtn(icon: Icons.add_rounded, onTap: onIncrement),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // class _StepperBtn extends StatelessWidget {
// //   final IconData icon; final VoidCallback onTap;
// //   const _StepperBtn({required this.icon, required this.onTap});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         width: 32, height: 32,
// //         decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
// //         child: Icon(icon, color: Colors.white, size: 18),
// //       ),
// //     );
// //   }
// // }
//
// // class _CartBanner extends StatelessWidget {
// //   final int quantity;
// //   const _CartBanner({required this.quantity});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: double.infinity,
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)]),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFFA5D6A7)),
// //       ),
// //       child: Row(children: [
// //         Container(
// //           width: 32, height: 32,
// //           decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
// //           child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 16),
// //         ),
// //         const SizedBox(width: 10),
// //         Text(
// //           quantity == 0 ? 'Your cart is empty' : '$quantity item${quantity > 1 ? 's' : ''} added to cart',
// //           style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 14),
// //         ),
// //         const Spacer(),
// //         if (quantity > 0) const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
// //       ]),
// //     );
// //   }
// // }
//
// // class _SectionCard extends StatelessWidget {
// //   final String title; final Widget child;
// //   const _SectionCard({required this.title, required this.child});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
// //       ),
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3)),
// //         const SizedBox(height: 14),
// //         child,
// //       ]),
// //     );
// //   }
// // }
//
// // class _FeatureItem extends StatelessWidget {
// //   final String label; final IconData icon; final Color color;
// //   const _FeatureItem({required this.label, required this.icon, required this.color});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: Row(children: [
// //         Container(
// //           width: 36, height: 36,
// //           decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
// //           child: Icon(icon, color: color, size: 18),
// //         ),
// //         const SizedBox(width: 12),
// //         Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
// //       ]),
// //     );
// //   }
// // }
