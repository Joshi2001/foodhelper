import 'dart:convert';
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Screens/Auth/login_screen.dart';
import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Services/Providers/auth.provider.dart';
import 'package:e_commerce/Services/Providers/orderprovider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_gift_cart_screen.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_cart_screen.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_cancellation_policy.dart';
import 'package:e_commerce/UI/Widgets/Organisms/card_apply_coupon.dart';
import 'package:e_commerce/UI/Widgets/address/add_address.dart';
import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? fullAddressData;
  String selectedAddress = 'Add delivery address';
  String addressLabel = 'Home';
  bool _isProcessingPayment = false;
  double _deliveryCharge = 0;
  double _handlingCharge = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Home>(context, listen: false).loadCart();
      _loadServiceAreas();
    });
  }

  Future<void> _loadServiceAreas() async {
    final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    if (serviceProvider.serviceCities.isEmpty) {
      await serviceProvider.fetchServiceAreas();
      if (fullAddressData != null) {
        await _updateCharges();
      }
    }
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_address');
    if (saved != null) {
      final address = jsonDecode(saved);
      setState(() {
        fullAddressData = address;
        selectedAddress = _formatAddress(address);
        addressLabel = 'Home';
      });
      await _updateCharges();
    }
  }

  Future<void> _updateCharges() async {
    if (fullAddressData == null) {
      debugPrint("⚠️ No address available, setting charges to 0");
      setState(() {
        _deliveryCharge = 0;
        _handlingCharge = 0;
      });
      return;
    }
    
    final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    
    if (serviceProvider.serviceCities.isEmpty) {
      await serviceProvider.fetchServiceAreas();
    }
    
    var charges = serviceProvider.getChargesForLocation(
      city: fullAddressData?['city'],
      pincode: fullAddressData?['pincode'],
      areaName: fullAddressData?['area'],
      address: fullAddressData?['address'],
    );
    
    if (charges['deliveryCharge'] == 0 && charges['handlingCharge'] == 0) {
      for (var city in serviceProvider.serviceCities) {
        for (var area in city.areas) {
          final addressText = (fullAddressData?['address'] ?? '').toLowerCase();
          final areaName = area.name.toLowerCase();
          
          if (addressText.contains(areaName)) {
            charges = {
              'deliveryCharge': area.deliveryCharge,
              'handlingCharge': area.handlingCharge,
            };
            break;
          }
        }
      }
    }
    
    final delivery = charges['deliveryCharge'] ?? 0;
    final handling = charges['handlingCharge'] ?? 0;
    
    setState(() {
      _deliveryCharge = delivery;
      _handlingCharge = handling;
    });
  }

  Future<void> _placeCodOrder() async {
    if (_isProcessingPayment) return;

    // ✅ Check login before placing order
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      await _showLoginRequiredDialog();
      return;
    }

    if (fullAddressData == null) {
      _showSnack('Please add delivery address first', Colors.red);
      return;
    }

    final isServiceable = await _validateServiceability();
    if (!isServiceable) return;

    final cartProvider = Provider.of<Home>(context, listen: false);
    final cartItems = cartProvider.getCartItemsLocal();

    if (cartItems.isEmpty) {
      _showSnack('Your cart is empty', Colors.red);
      return;
    }

    await _updateCharges();

    setState(() => _isProcessingPayment = true);

    try {
      final token = authProvider.token;

      if (token == null) {
        _showSnack('Session expired. Please login again', Colors.red);
        return;
      }

      await _saveAddressOnce(fullAddressData!);

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);

      final String? activeCoupon = couponProvider.isCouponApplied &&
              (couponProvider.appliedCouponCode?.isNotEmpty ?? false)
          ? couponProvider.appliedCouponCode
          : null;

      final success = await orderProvider.createOrder(
        token: token,
        address: fullAddressData!,
        cartItems: cartItems,
        couponCode: activeCoupon,
        deliveryCharge: _deliveryCharge,
        handlingCharge: _handlingCharge,
        getFinalPrice: (dynamic product, int quantity) =>
            cartProvider.getFinalPrice(product as Product, quantity),
      );

      couponProvider.removeCoupon();

      if (!success) {
        _showSnack('Order failed. Try again.', Colors.red);
        return;
      }

      await cartProvider.clearCartAfterOrder();
      await orderProvider.fetchMyOrders(token);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/orders');
      _showSnack('Order placed! Pay on delivery.', Colors.green);
    } catch (e) {
      _showSnack('Something went wrong: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  // ✅ Login Dialog - Shows only when needed
  Future<void> _showLoginRequiredDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Login Required'),
          ],
        ),
        content: const Text(
          'Please login to place your order and proceed with checkout.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel',style: TextStyle(color: Colors.black,fontSize: 12),),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); 
              
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              
              if (mounted) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.isLoggedIn) {
                  _placeCodOrder();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Login Now',style: TextStyle(color: Colors.white,fontSize: 12),),
          ),
        ],
      ),
    );
  }

  Future<bool> _validateServiceability() async {
    if (fullAddressData == null) {
      _showSnack('Please add delivery address first', Colors.red);
      return false;
    }
    
    final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    
    final isServiceable = serviceProvider.isLocationServiceableByAddress(
      address: fullAddressData?['address'],
      city: fullAddressData?['city'],
      areaName: fullAddressData?['area'],
      pincode: fullAddressData?['pincode'],
    );
    
    if (!isServiceable) {
      final serviceableCities = serviceProvider.getServiceableCities().join(', ');
      _showSnack(
        'Delivery not available at this address.\nServiceable areas: $serviceableCities', 
        Colors.red
      );
      return false;
    }
    
    return true;
  }

  Future<void> _forceClearInvalidCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartProvider = Provider.of<Home>(context, listen: false);
    await prefs.remove('cart_items');
    await cartProvider.clearCartAfterOrder();
    await cartProvider.loadCart();
    _showSnack('Cart cleared. Please refresh products and add again.', Colors.orange);
    setState(() {});
  }

  Future<void> _saveAddressOnce(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('saved_address')) {
      await prefs.setString('saved_address', jsonEncode(address));
    }
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

  Future<void> _validateAndClearInvalidCart() async {
    final cartProvider = Provider.of<Home>(context, listen: false);
    final cartItems = cartProvider.getCartItemsLocal();
    bool hasInvalidItems = false;
    for (final item in cartItems) {
      if (item.product.id.isEmpty || item.product.id.length < 20) {
        hasInvalidItems = true;
        break;
      }
    }
    if (hasInvalidItems && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Cart Items'),
          content: const Text(
            'Some items in your cart are no longer available. Would you like to clear your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _forceClearInvalidCart();
              },
              child: const Text('Clear Cart'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddress(
          onAddressSelected: (addressData) async {
            debugPrint("📍 ADDRESS SELECTED:");
            debugPrint("   Full Address Data: $addressData");
            debugPrint("   City: ${addressData['city']}");
            debugPrint("   Area: ${addressData['area']}");
            debugPrint("   Pincode: ${addressData['pincode']}");
            
            setState(() {
              fullAddressData = addressData;
              selectedAddress = _formatAddress(addressData);
              addressLabel = 'Home';
            });
            await _saveAddressToPrefs(addressData);
            await _updateCharges();
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveAddressToPrefs(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_address', jsonEncode(address));
  }

  String _formatAddress(Map<String, dynamic> addressData) {
    final parts = [
      addressData['house'] ?? '',
      addressData['building'] ?? '',
      addressData['landmark'] ?? '',
      addressData['address'] ?? '',
    ].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'No address selected';
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<dynamic> _getSimilarProducts(Home homeProvider) {
    final cartItems = homeProvider.getCartItemsLocal();
    final cartIds = cartItems.map((e) => e.product.id).toSet();
    return homeProvider.products
        .where((p) => !cartIds.contains(p.id))
        .take(20)
        .toList();
  }

  Widget _buildSimilarProductsSection(Home homeProvider) {
    final similar = _getSimilarProducts(homeProvider);
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 226, 237, 249),
        appBar: AppBar(
          backgroundColor: AppColors.primaryOrangeColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Checkout',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () async {
                final cartProvider = Provider.of<Home>(context, listen: false);
                await cartProvider.clearCartAfterOrder();
                await cartProvider.loadCart();
                _showSnack('Cart cleared', Colors.orange);
                setState(() {});
              },
            ),
          ],
        ),
        body: Consumer3<Home, CouponProvider, ServiceAreaProvider>(
          builder: (context, homeProvider, couponProvider, serviceProvider, _) {
            final cartItems = homeProvider.getCartItemsLocal();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _validateAndClearInvalidCart();
            });

            if (cartItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text('Your cart is empty',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    Text('Add items to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 8, bottom: 180),
                  children: [
                    _buildDeliveryCard(cartItems),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) =>
                            CartProductCard(index: index),
                      ),
                    ),

                    const SizedBox(height: 12),
                    ApplyCouponOnCartCard(),
                    const SizedBox(height: 12),
                    _buildBillDetailsCard(homeProvider, couponProvider),

                    const SizedBox(height: 12),
                    _buildSimilarProductsSection(homeProvider),
                    const SizedBox(height: 12),
                    OrderGiftCard(),
                    const SizedBox(height: 12),
                    CancellationPolicyCard(),
                  ],
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAddressSection(),
                        const SizedBox(height: 12),
                        _buildCodButton(homeProvider, couponProvider),
                      ],
                    ),
                  ),
                ),

                if (_isProcessingPayment)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Placing your order...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(List<dynamic> cartItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.primaryOrangeColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Delivery in ',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                      ),
                    ),
                    Text(
                      '28 mins',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryOrangeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Shipment of ${cartItems.length} ${cartItems.length > 1 ? 'items' : 'item'}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetailsCard(
    Home homeProvider, CouponProvider couponProvider) {
    final cartItems = homeProvider.getCartItemsLocal();
    final productSubtotal = cartItems.fold<double>(0, (sum, item) {
      return sum +
          (homeProvider.getFinalPrice(item.product, item.quantity) *
              item.quantity);
    });
    
    final discount = couponProvider.discountAmount;
    final totalAfterDiscount = productSubtotal - discount;
    final finalTotal = totalAfterDiscount + _deliveryCharge + _handlingCharge;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bill Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildBillRow('Product Subtotal', '₹${productSubtotal.toStringAsFixed(2)}'),
          
          _buildBillRow('Delivery Charge', '₹${_deliveryCharge.toStringAsFixed(2)}'),
          
          _buildBillRow('Handling Charge', '₹${_handlingCharge.toStringAsFixed(2)}'),
          
          if (discount > 0) ...[
            const SizedBox(height: 6),
            _buildBillRow(
              'Coupon Discount (${couponProvider.appliedCouponCode ?? ''})',
              '- ₹${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          
          const Divider(height: 16),
          _buildBillRow(
            'Grand Total',
            '₹${finalTotal.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 16,
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '* Includes delivery & handling charges',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodButton(Home homeProvider, CouponProvider couponProvider) {
    final cartItems = homeProvider.getCartItemsLocal();
    final productSubtotal = cartItems.fold<double>(0, (sum, item) {
      return sum +
          (homeProvider.getFinalPrice(item.product, item.quantity) *
              item.quantity);
    });
    final totalAfterDiscount = productSubtotal - couponProvider.discountAmount;
    final finalTotal = totalAfterDiscount + _deliveryCharge + _handlingCharge;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _placeCodOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrangeColor,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.money, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Place Order · ₹${finalTotal.toStringAsFixed(2)} (COD)',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {bool isBold = false, bool isDiscount = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    final bool hasAddress = fullAddressData != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: !hasAddress
            ? Border.all(
                color: AppColors.primaryOrangeColor.withOpacity(0.3),
                width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Icon(hasAddress ? Icons.home : Icons.add_location_alt_outlined,
              color: AppColors.primaryOrangeColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAddress ? 'Delivering to $addressLabel' : 'Add Delivery Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasAddress ? Colors.black : Colors.grey[700],
                  ),
                ),
                Text(
                  hasAddress ? selectedAddress : 'Tap to add your delivery address',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: hasAddress ? FontStyle.normal : FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _selectAddress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasAddress ? 'Change' : 'Add',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryOrangeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  hasAddress ? Icons.edit : Icons.add,
                  color: AppColors.primaryOrangeColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing _SimilarProductCard class as is
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

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.product.basePrice;
    final double salePrice = widget.product.salePrice;
    final bool hasDiscount = salePrice > 0 && salePrice < basePrice;
    final double displayPrice = salePrice > 0 ? salePrice : basePrice;

    return Consumer2<Home, WishlistProvider>(
      builder: (context, homeProvider, wishlistProvider, _) {
        final int qty = _getQty(homeProvider);
        final bool isWishlisted = wishlistProvider.isWishlisted(widget.product.id);
        final bool isWishlistLoading = wishlistProvider.isProductLoading(widget.product.id);

        return Container(
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
                            '${(((basePrice - salePrice) / basePrice) * 100).round()}% OFF',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          wishlistProvider.toggleWishlist(widget.product.id, 'admin');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: isWishlistLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : Icon(
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  color: isWishlisted ? Colors.red : Colors.grey,
                                  size: 18,
                                ),
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
                                  '₹${basePrice.toStringAsFixed(0)}',
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
// import 'dart:convert';
// import 'package:e_commerce/Models/product.dart';
// import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
// import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
// import 'package:e_commerce/Services/Providers/orderprovider.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_gift_cart_screen.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_product_cart_screen.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/card_cancellation_policy.dart';
// import 'package:e_commerce/UI/Widgets/Organisms/card_apply_coupon.dart';
// import 'package:e_commerce/UI/Widgets/address/add_address.dart';
// import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../app_colors.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   Map<String, dynamic>? fullAddressData;
//   String selectedAddress = 'Add delivery address';
//   String addressLabel = 'Home';
//   bool _isProcessingPayment = false;
//   double _deliveryCharge = 0;
//   double _handlingCharge = 0;

// @override
// void initState() {
//   super.initState();
//   _loadSavedAddress();
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     Provider.of<Home>(context, listen: false).loadCart();
//     _loadServiceAreas(); // Make sure this is called
//   });
// }

// Future<void> _loadServiceAreas() async {
//   final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
//   if (serviceProvider.serviceCities.isEmpty) {
//     await serviceProvider.fetchServiceAreas();
//     // After loading, update charges if address exists
//     if (fullAddressData != null) {
//       await _updateCharges();
//     }
//   }
// }
//   Future<void> _loadSavedAddress() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString('saved_address');
//     if (saved != null) {
//       final address = jsonDecode(saved);
//       setState(() {
//         fullAddressData = address;
//         selectedAddress = _formatAddress(address);
//         addressLabel = 'Home';
//       });
//       await _updateCharges();
//     }
//   }

//   Future<void> _updateCharges() async {
//   if (fullAddressData == null) {
//     debugPrint("⚠️ No address available, setting charges to 0");
//     setState(() {
//       _deliveryCharge = 0;
//       _handlingCharge = 0;
//     });
//     return;
//   }
  
//   final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
  
//   // Wait for service areas to load
//   if (serviceProvider.serviceCities.isEmpty) {
//     await serviceProvider.fetchServiceAreas();
//   }
  
//   // Try to find matching service area
//   var charges = serviceProvider.getChargesForLocation(
//     city: fullAddressData?['city'],
//     pincode: fullAddressData?['pincode'],
//     areaName: fullAddressData?['area'],
//     address: fullAddressData?['address'],
//   );
  
//   // If no charges found, try partial matching
//   if (charges['deliveryCharge'] == 0 && charges['handlingCharge'] == 0) {
//     debugPrint("⚠️ No exact match found, trying partial match...");
    
//     for (var city in serviceProvider.serviceCities) {
//       for (var area in city.areas) {
//         final addressText = (fullAddressData?['address'] ?? '').toLowerCase();
//         final areaName = area.name.toLowerCase();
        
//         if (addressText.contains(areaName)) {
//           debugPrint("✅ Found partial match: Area '${area.name}'");
//           charges = {
//             'deliveryCharge': area.deliveryCharge,
//             'handlingCharge': area.handlingCharge,
//           };
//           break;
//         }
//       }
//     }
//   }
//   final delivery = charges['deliveryCharge'] ?? 0;
//   final handling = charges['handlingCharge'] ?? 0;
  
//   debugPrint("💰 FINAL CHARGES CALCULATED:");
//   debugPrint("   Delivery: ₹$delivery");
//   debugPrint("   Handling: ₹$handling");
  
//   setState(() {
//     _deliveryCharge = delivery;
//     _handlingCharge = handling;
//   });
// }

// Future<void> _placeCodOrder() async {
//   if (_isProcessingPayment) return;

//   if (fullAddressData == null) {
//     _showSnack('Please add delivery address first', Colors.red);
//     return;
//   }

//   final isServiceable = await _validateServiceability();
//   if (!isServiceable) return;

//   final cartProvider = Provider.of<Home>(context, listen: false);
//   final cartItems = cartProvider.getCartItemsLocal();

//   if (cartItems.isEmpty) {
//     _showSnack('Your cart is empty', Colors.red);
//     return;
//   }

//   await _updateCharges();
  
//   debugPrint("💰 CHARGES BEFORE ORDER:");
//   debugPrint("   Delivery Charge: $_deliveryCharge");
//   debugPrint("   Handling Charge: $_handlingCharge");

//   setState(() => _isProcessingPayment = true);

//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       _showSnack('Session expired. Please login again', Colors.red);
//       return;
//     }

//     await _saveAddressOnce(fullAddressData!);

//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     final couponProvider = Provider.of<CouponProvider>(context, listen: false);

//     final String? activeCoupon = couponProvider.isCouponApplied &&
//             (couponProvider.appliedCouponCode?.isNotEmpty ?? false)
//         ? couponProvider.appliedCouponCode
//         : null;

//     final success = await orderProvider.createOrder(
//       token: token,
//       address: fullAddressData!,
//       cartItems: cartItems,
//       couponCode: activeCoupon,
//       deliveryCharge: _deliveryCharge, 
//       handlingCharge: _handlingCharge, 
//       getFinalPrice: (dynamic product, int quantity) => 
//       cartProvider.getFinalPrice(product as Product, quantity),
//     );

//     couponProvider.removeCoupon();

//     if (!success) {
//       _showSnack('Order failed. Try again.', Colors.red);
//       return;
//     }

//     await cartProvider.clearCartAfterOrder();
//     await orderProvider.fetchMyOrders(token);

//     if (!mounted) return;

//     Navigator.pushReplacementNamed(context, '/orders');
//     _showSnack('Order placed! Pay on delivery.', Colors.green);
//   } catch (e) {
//     _showSnack('Something went wrong: $e', Colors.red);
//   } finally {
//     if (mounted) setState(() => _isProcessingPayment = false);
//   }
// }

//   Future<bool> _validateServiceability() async {
//     if (fullAddressData == null) {
//       _showSnack('Please add delivery address first', Colors.red);
//       return false;
//     }
    
//     final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    
//     final isServiceable = serviceProvider.isLocationServiceableByAddress(
//       address: fullAddressData?['address'],
//       city: fullAddressData?['city'],
//       areaName: fullAddressData?['area'],
//       pincode: fullAddressData?['pincode'],
//     );
    
//     if (!isServiceable) {
//       final serviceableCities = serviceProvider.getServiceableCities().join(', ');
//       _showSnack(
//         'Delivery not available at this address.\nServiceable areas: $serviceableCities', 
//         Colors.red
//       );
//       return false;
//     }
    
//     return true;
//   }

//   Future<void> _forceClearInvalidCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartProvider = Provider.of<Home>(context, listen: false);
//     await prefs.remove('cart_items');
//     await cartProvider.clearCartAfterOrder();
//     await cartProvider.loadCart();
//     _showSnack('Cart cleared. Please refresh products and add again.', Colors.orange);
//     setState(() {});
//   }

//   Future<void> _saveAddressOnce(Map<String, dynamic> address) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('saved_address')) {
//       await prefs.setString('saved_address', jsonEncode(address));
//     }
//   }

//   void _showSnack(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> _validateAndClearInvalidCart() async {
//     final cartProvider = Provider.of<Home>(context, listen: false);
//     final cartItems = cartProvider.getCartItemsLocal();
//     bool hasInvalidItems = false;
//     for (final item in cartItems) {
//       if (item.product.id.isEmpty || item.product.id.length < 20) {
//         hasInvalidItems = true;
//         break;
//       }
//     }
//     if (hasInvalidItems && mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Invalid Cart Items'),
//           content: const Text(
//             'Some items in your cart are no longer available. Would you like to clear your cart?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(ctx);
//                 await _forceClearInvalidCart();
//               },
//               child: const Text('Clear Cart'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Future<void> _selectAddress() async {
//   await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => AddAddress(
//         onAddressSelected: (addressData) async {
//           debugPrint("📍 ADDRESS SELECTED:");
//           debugPrint("   Full Address Data: $addressData");
//           debugPrint("   City: ${addressData['city']}");
//           debugPrint("   Area: ${addressData['area']}");
//           debugPrint("   Pincode: ${addressData['pincode']}");
          
//           setState(() {
//             fullAddressData = addressData;
//             selectedAddress = _formatAddress(addressData);
//             addressLabel = 'Home';
//           });
//           await _saveAddressToPrefs(addressData);
//           await _updateCharges();
//           if (mounted) {
//             Navigator.pop(context);
//           }
//         },
//       ),
//     ),
//   );
// }

//   Future<void> _saveAddressToPrefs(Map<String, dynamic> address) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('saved_address', jsonEncode(address));
//   }

//   String _formatAddress(Map<String, dynamic> addressData) {
//     final parts = [
//       addressData['house'] ?? '',
//       addressData['building'] ?? '',
//       addressData['landmark'] ?? '',
//       addressData['address'] ?? '',
//     ].where((e) => e.isNotEmpty).toList();
//     return parts.isNotEmpty ? parts.join(', ') : 'No address selected';
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   List<dynamic> _getSimilarProducts(Home homeProvider) {
//     final cartItems = homeProvider.getCartItemsLocal();
//     final cartIds = cartItems.map((e) => e.product.id).toSet();
//     return homeProvider.products
//         .where((p) => !cartIds.contains(p.id))
//         .take(20)
//         .toList();
//   }

//   Widget _buildSimilarProductsSection(Home homeProvider) {
//     final similar = _getSimilarProducts(homeProvider);
//     if (similar.isEmpty) return const SizedBox.shrink();

//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(8)),
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 4,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryOrangeColor,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text('You might also like',
//                         style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87)),
//                   ],
//                 ),
//                 Text('${similar.length} items',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 220,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               itemCount: similar.length,
//               itemBuilder: (context, index) {
//                 final product = similar[index];
//                 return _SimilarProductCard(
//                   product: product,
//                   onAddedToCart: () {
//                     _showSnack('${product.name} added to cart!',
//                         AppColors.primaryOrangeColor);
//                     setState(() {});
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: const Color.fromARGB(255, 226, 237, 249),
//         appBar: AppBar(
//           backgroundColor: AppColors.primaryOrangeColor,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text('Checkout',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold)),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.white),
//               onPressed: () async {
//                 final cartProvider = Provider.of<Home>(context, listen: false);
//                 await cartProvider.clearCartAfterOrder();
//                 await cartProvider.loadCart();
//                 _showSnack('Cart cleared', Colors.orange);
//                 setState(() {});
//               },
//             ),
//           ],
//         ),
//         body: Consumer3<Home, CouponProvider, ServiceAreaProvider>(
//           builder: (context, homeProvider, couponProvider, serviceProvider, _) {
//             final cartItems = homeProvider.getCartItemsLocal();

//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _validateAndClearInvalidCart();
//             });

//             if (cartItems.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.shopping_cart_outlined,
//                         size: 100, color: Colors.grey[300]),
//                     const SizedBox(height: 20),
//                     Text('Your cart is empty',
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[600])),
//                     const SizedBox(height: 10),
//                     Text('Add items to get started',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[500])),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Start Shopping'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Stack(
//               children: [
//                 ListView(
//                   padding: const EdgeInsets.only(
//                       left: 12, right: 12, top: 8, bottom: 180),
//                   children: [
//                     _buildDeliveryCard(cartItems),
//                     const SizedBox(height: 12),

//                     Container(
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: ListView.builder(
//                         itemCount: cartItems.length,
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemBuilder: (context, index) =>
//                             CartProductCard(index: index),
//                       ),
//                     ),

//                     const SizedBox(height: 12),
//                     ApplyCouponOnCartCard(),
//                     const SizedBox(height: 12),
//                     _buildBillDetailsCard(homeProvider, couponProvider),

//                     const SizedBox(height: 12),
//                     _buildSimilarProductsSection(homeProvider),
//                     const SizedBox(height: 12),
//                     OrderGiftCard(),
//                     const SizedBox(height: 12),
//                     CancellationPolicyCard(),
//                   ],
//                 ),

//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     color: Colors.white,
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildAddressSection(),
//                         const SizedBox(height: 12),
//                         _buildCodButton(homeProvider, couponProvider),
//                       ],
//                     ),
//                   ),
//                 ),

//                 if (_isProcessingPayment)
//                   Container(
//                     color: Colors.black54,
//                     child: const Center(
//                       child: Card(
//                         child: Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               CircularProgressIndicator(),
//                               SizedBox(height: 16),
//                               Text('Placing your order...'),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDeliveryCard(List<dynamic> cartItems) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.orange.shade50),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primaryOrangeColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.timer_outlined,
//               color: AppColors.primaryOrangeColor,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Text(
//                       'Delivery in ',
//                       style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87
//                       ),
//                     ),
//                     Text(
//                       '28 mins',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w900,
//                         color: AppColors.primaryOrangeColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Shipment of ${cartItems.length} ${cartItems.length > 1 ? 'items' : 'item'}',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade500,
//                       fontWeight: FontWeight.w500
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _buildBillDetailsCard(
//   Home homeProvider, CouponProvider couponProvider) {
//   final cartItems = homeProvider.getCartItemsLocal();
//   final productSubtotal = cartItems.fold<double>(0, (sum, item) {
//     return sum +
//         (homeProvider.getFinalPrice(item.product, item.quantity) *
//             item.quantity);
//   });
  
//   final discount = couponProvider.discountAmount;
//   final totalAfterDiscount = productSubtotal - discount;
//   final finalTotal = totalAfterDiscount + _deliveryCharge + _handlingCharge;

//   return Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//         color: Colors.white, borderRadius: BorderRadius.circular(8)),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Bill Details',
//             style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 10),
//         _buildBillRow('Product Subtotal', '₹${productSubtotal.toStringAsFixed(2)}'),
        
//         // Always show delivery charge if it exists, even if 0
//         _buildBillRow('Delivery Charge', '₹${_deliveryCharge.toStringAsFixed(2)}'),
        
//         // Always show handling charge if it exists, even if 0
//         _buildBillRow('Handling Charge', '₹${_handlingCharge.toStringAsFixed(2)}'),
        
//         if (discount > 0) ...[
//           const SizedBox(height: 6),
//           _buildBillRow(
//             'Coupon Discount (${couponProvider.appliedCouponCode ?? ''})',
//             '- ₹${discount.toStringAsFixed(2)}',
//             isDiscount: true,
//           ),
//         ],
        
//         const Divider(height: 16),
//         _buildBillRow(
//           'Grand Total',
//           '₹${finalTotal.toStringAsFixed(2)}',
//           isBold: true,
//           fontSize: 16,
//         ),
        
//         Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(
//             '* Includes delivery & handling charges',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _buildCodButton(Home homeProvider, CouponProvider couponProvider) {
//     final cartItems = homeProvider.getCartItemsLocal();
//     final productSubtotal = cartItems.fold<double>(0, (sum, item) {
//       return sum +
//           (homeProvider.getFinalPrice(item.product, item.quantity) *
// item.quantity);
//     });
//     final totalAfterDiscount = productSubtotal - couponProvider.discountAmount;
//     final finalTotal = totalAfterDiscount + _deliveryCharge + _handlingCharge;

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isProcessingPayment ? null : _placeCodOrder,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryOrangeColor,
//           disabledBackgroundColor: Colors.grey,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//         ),
//         child: _isProcessingPayment
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2, color: Colors.white),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.money, color: Colors.white, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Place Order · ₹${finalTotal.toStringAsFixed(2)} (COD)',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildBillRow(String label, String value,
//       {bool isBold = false, bool isDiscount = false, double fontSize = 14}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: fontSize,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: isDiscount ? Colors.green : Colors.black87,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: fontSize,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: isDiscount ? Colors.green : Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddressSection() {
//     final bool hasAddress = fullAddressData != null;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: !hasAddress
//             ? Border.all(
//                 color: AppColors.primaryOrangeColor.withOpacity(0.3),
//                 width: 1.5)
//             : null,
//       ),
//       child: Row(
//         children: [
//           Icon(hasAddress ? Icons.home : Icons.add_location_alt_outlined,
//               color: AppColors.primaryOrangeColor, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   hasAddress ? 'Delivering to $addressLabel' : 'Add Delivery Address',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: hasAddress ? Colors.black : Colors.grey[700],
//                   ),
//                 ),
//                 Text(
//                   hasAddress ? selectedAddress : 'Tap to add your delivery address',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                     fontStyle: hasAddress ? FontStyle.normal : FontStyle.italic,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           InkWell(
//             onTap: _selectAddress,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   hasAddress ? 'Change' : 'Add',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: AppColors.primaryOrangeColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Icon(
//                   hasAddress ? Icons.edit : Icons.add,
//                   color: AppColors.primaryOrangeColor,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SimilarProductCard extends StatefulWidget {
//   final Product product;
//   final VoidCallback onAddedToCart;

//   const _SimilarProductCard({
//     required this.product,
//     required this.onAddedToCart,
//   });

//   @override
//   State<_SimilarProductCard> createState() => _SimilarProductCardState();
// }

// class _SimilarProductCardState extends State<_SimilarProductCard> {
//   bool _loading = false;

//   int _getQty(Home provider) => provider.getQuantity(widget.product.id);

//   Future<void> _addToCart(Home provider) async {
//     if (_loading) return;
//     setState(() => _loading = true);
//     try {
//       provider.updateQuantity(widget.product.id, 1);
//       await provider.addToCart(widget.product.id, 1);
//       widget.onAddedToCart();
//     } catch (e) {
//       debugPrint('❌ addToCart error: $e');
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _increment(Home provider) async {
//     if (_loading) return;
//     setState(() => _loading = true);
//     try {
//       final newQty = _getQty(provider) + 1;
//       provider.updateQuantity(widget.product.id, newQty);
//       await provider.addToCart(widget.product.id, newQty);
//     } catch (e) {
//       debugPrint('❌ increment error: $e');
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _decrement(Home provider) async {
//     if (_loading) return;
//     setState(() => _loading = true);
//     try {
//       final currentQty = _getQty(provider);
//       if (currentQty <= 1) {
//         provider.updateQuantity(widget.product.id, 0);
//         await provider.removeFromCart(widget.product.id);
//       } else {
//         final newQty = currentQty - 1;
//         provider.updateQuantity(widget.product.id, newQty);
//         await provider.addToCart(widget.product.id, newQty);
//       }
//     } catch (e) {
//       debugPrint('❌ decrement error: $e');
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double basePrice = widget.product.basePrice;
//     final double salePrice = widget.product.salePrice;
//     final bool hasDiscount = salePrice > 0 && salePrice < basePrice;
//     final double displayPrice = salePrice > 0 ? salePrice : basePrice;

//     return Consumer2<Home, WishlistProvider>(
//       builder: (context, homeProvider, wishlistProvider, _) {
//         final int qty = _getQty(homeProvider);
//         final bool isWishlisted = wishlistProvider.isWishlisted(widget.product.id);
//         final bool isWishlistLoading = wishlistProvider.isProductLoading(widget.product.id);

//         return Container(
//           width: 155,
//           margin: const EdgeInsets.only(right: 14, bottom: 5, top: 5),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: Colors.grey.shade100),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                 child: Stack(
//                   children: [
//                     Container(
//                       height: 94,
//                       width: double.infinity,
//                       color: const Color(0xFFF8F9FB),
//                       padding: const EdgeInsets.all(10),
//                       child: widget.product.imagePath.isNotEmpty
//                           ? Image.network(
//                         widget.product.imagePath,
//                         fit: BoxFit.contain,
//                         errorBuilder: (_, __, ___) => _imagePlaceholder(),
//                       )
//                           : _imagePlaceholder(),
//                     ),
//                     if (hasDiscount)
//                       Positioned(
//                         top: 0,
//                         left: 0,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: const BoxDecoration(
//                             color: Color(0xFF2563EB),
//                             borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
//                           ),
//                           child: Text(
//                             '${(((basePrice - salePrice) / basePrice) * 100).round()}% OFF',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w900),
//                           ),
//                         ),
//                       ),
//                     // Add Wishlist Button
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: () {
//                           wishlistProvider.toggleWishlist(widget.product.id, 'admin');
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                               ),
//                             ],
//                           ),
//                           child: isWishlistLoading
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.red,
//                                   ),
//                                 )
//                               : Icon(
//                                   isWishlisted ? Icons.favorite : Icons.favorite_border,
//                                   color: isWishlisted ? Colors.red : Colors.grey,
//                                   size: 18,
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (widget.product.weight != null)
//                       Text(
//                         '${widget.product.weight!.value}${widget.product.weight!.unit}',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey.shade500,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     const SizedBox(height: 2),
//                     Text(
//                       widget.product.name,
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1F2937),
//                           height: 1.2),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (hasDiscount)
//                                 Text(
//                                   '₹${basePrice.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.grey.shade400,
//                                       decoration: TextDecoration.lineThrough),
//                                 ),
//                               Text(
//                                 '₹${displayPrice.toStringAsFixed(0)}',
//                                 style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.black),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           width: 65,
//                           height: 32,
//                           child: _loading
//                               ? const Center(
//                             child: SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: AppColors.primaryOrangeColor,
//                               ),
//                             ),
//                           )
//                               : qty == 0
//                               ? OutlinedButton(
//                             onPressed: () => _addToCart(homeProvider),
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: Color(0xFFE5E7EB)),
//                               padding: EdgeInsets.zero,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                               backgroundColor: Colors.white,
//                             ),
//                             child: const Text(
//                               'ADD',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   color: Color(0xFF003D73),
//                                   fontWeight: FontWeight.w800),
//                             ),
//                           )
//                               : Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF003D73),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () => _decrement(homeProvider),
//                                     child: const Icon(Icons.remove,
//                                         size: 14, color: Colors.white),
//                                   ),
//                                 ),
//                                 Text(
//                                   '$qty',
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white),
//                                 ),
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () => _increment(homeProvider),
//                                     child: const Icon(Icons.add,
//                                         size: 14, color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
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

//   Widget _imagePlaceholder() {
//     return Container(
//       color: Colors.grey[100],
//       child: const Center(
//         child: Icon(Icons.image_not_supported_outlined,
//             color: Colors.grey, size: 32),
//       ),
//     );
//   }
// }
