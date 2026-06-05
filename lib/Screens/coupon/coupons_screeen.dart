import 'package:e_commerce/Screens/coupon/coupon_model.dart';
import 'package:e_commerce/Screens/coupon/coupon_service.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';

class CouponsSelectionScreen extends StatefulWidget {
  final double? orderTotal;
  
  const CouponsSelectionScreen({super.key, this.orderTotal});

  @override
  State<CouponsSelectionScreen> createState() => _CouponsSelectionScreenState();
}

class _CouponsSelectionScreenState extends State<CouponsSelectionScreen> {
  final TextEditingController _couponController = TextEditingController();
  final CouponService _couponService = CouponService();
  
  List<Coupon> _coupons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coupons = await _couponService.getCoupons();
      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _validateMinimumOrder(Coupon coupon) {
    final orderTotal = widget.orderTotal ?? 0.0;
    
    if (orderTotal < coupon.minOrderValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Minimum order value of ₹${coupon.minOrderValue.toStringAsFixed(0)} required to apply this coupon",
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _applyCoupon(String couponCode) async {
    final coupon = _coupons.firstWhere(
      (c) => c.couponCode == couponCode,
      orElse: () => _coupons.first,
    );
    
    if (!_validateMinimumOrder(coupon)) {
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await _couponService.applyCoupon(
        couponCode, 
        widget.orderTotal ?? 0.0
      );
      
      Navigator.pop(context);
      
      if (response.success) {
        final successResponse = ApplyCouponResponse(
          success: true,
          discountAmount: response.discountAmount,
          finalTotal: response.finalTotal,
          message: response.message,
          couponCode: couponCode,
        );
        
        Navigator.pop(context, successResponse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, response);
      }
    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to apply coupon: ${e.toString().replaceAll('Exception:', '')}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _applyEnteredCoupon() async {
    final couponCode = _couponController.text.trim();
    
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a coupon code"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final coupon = _coupons.firstWhere(
      (c) => c.couponCode == couponCode,
      orElse: () => Coupon(
        couponCode: '',
        headline: '',
        discountType: 'flat',
        discountValue: 0,
        minOrderValue: 0,
        maxDiscount: 0,
        expiryDate: DateTime.now(),
        isActive: false,
        dataPoints: [],
      ),
    );
    
    if (coupon.couponCode.isEmpty) {
      await _applyCoupon(couponCode);
    } else {
      if (_validateMinimumOrder(coupon)) {
        await _applyCoupon(couponCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrangeColor,
        elevation: 0,
        leadingWidth: 25,
        automaticallyImplyLeading: true,
        title: const Text(
          "Available Coupons",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.orderTotal != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryOrangeColor.withOpacity(0.1), AppColors.primaryOrangeColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryOrangeColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.shopping_cart, size: 18, color: AppColors.primaryOrangeColor),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Total",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.orderTotal!.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrangeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _couponController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.local_offer_outlined, size: 20, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _applyEnteredCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(90, 45),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Apply',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
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
                  const Text(
                    "Best Offers For You",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _buildCouponsList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCouponsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryOrangeColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadCoupons,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No coupons available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _coupons.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        final orderTotal = widget.orderTotal ?? 0.0;
        final isMinOrderMet = orderTotal >= coupon.minOrderValue;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Stack(
            children: [
              // Premium badge for high value coupons
              if (coupon.discountValue >= 100)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "PREMIUM",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Coupon icon and vertical divider
                    SizedBox(
                      width: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryOrangeColor.withOpacity(0.15),
                                  AppColors.primaryOrangeColor.withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color: AppColors.primaryOrangeColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Middle: Coupon info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.headline,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrangeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primaryOrangeColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              coupon.couponCode,
                              style: TextStyle(
                                color: AppColors.primaryOrangeColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getDiscountText(coupon),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Fixed: Wrap in Container with constraints to prevent overflow
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.currency_rupee, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 2),
                                Text(
                                  "Min. ${coupon.minOrderValue.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMinOrderMet ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isMinOrderMet && coupon.isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "Need ₹${(coupon.minOrderValue - orderTotal).toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (coupon.maxDiscount > 0 && coupon.discountType == 'percentage')
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, size: 10, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Max ₹${coupon.maxDiscount.toStringAsFixed(0)} off",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (coupon.expiryDate.isBefore(DateTime.now()))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.watch_later_outlined, size: 10, color: Colors.red.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Expired: ${_formatDate(coupon.expiryDate)}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ...coupon.dataPoints.map<Widget>((e) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 4, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    
                    // Right: Apply button
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: (coupon.isActive && isMinOrderMet) 
                            ? () => _applyCoupon(coupon.couponCode) 
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (coupon.isActive && isMinOrderMet) 
                              ? Colors.green 
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(70, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          !coupon.isActive 
                              ? "Expired" 
                              : !isMinOrderMet 
                                  ? "Add ₹${(coupon.minOrderValue - orderTotal).toStringAsFixed(0)}" 
                                  : "Apply",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
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

  String _getDiscountText(Coupon coupon) {
    if (coupon.discountType == 'flat') {
      return "FLAT ₹${coupon.discountValue.toStringAsFixed(0)} OFF";
    } else {
      return "${coupon.discountValue.toStringAsFixed(0)}% OFF";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

// import 'package:e_commerce/Screens/coupon/coupon_model.dart';
// import 'package:e_commerce/Screens/coupon/coupon_service.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';

// class CouponsSelectionScreen extends StatefulWidget {
//   final double? orderTotal; // Optional: pass order total from previous screen
  
//   const CouponsSelectionScreen({super.key, this.orderTotal});

//   @override
//   State<CouponsSelectionScreen> createState() => _CouponsSelectionScreenState();
// }

// class _CouponsSelectionScreenState extends State<CouponsSelectionScreen> {
//   final TextEditingController _couponController = TextEditingController();
//   final CouponService _couponService = CouponService();
  
//   List<Coupon> _coupons = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadCoupons();
//   }

//   Future<void> _loadCoupons() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final coupons = await _couponService.getCoupons();
//       setState(() {
//         _coupons = coupons;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   // Add this method to your _CouponsSelectionScreenState class
// // Future<void> _applyCoupon(String couponCode) async {
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (context) => const Center(
// //       child: CircularProgressIndicator(),
// //     ),
// //   );

// //   try {
// //     final response = await _couponService.applyCoupon(
// //       couponCode, 
// //       widget.orderTotal ?? 0.0
// //     );
    
// //     Navigator.pop(context); // Close dialog
    
// //     if (response.success) {
// //       // Create a response with the coupon code
// //       final successResponse = ApplyCouponResponse(
// //         success: true,
// //         discountAmount: response.discountAmount,
// //         finalTotal: response.finalTotal,
// //         message: response.message,
// //         couponCode: couponCode, // IMPORTANT: Add the coupon code here
// //       );
      
// //       Navigator.pop(context, successResponse); // Return the response
// //     } else {
// //       // Return error response
// //       Navigator.pop(context, response);
// //     }
// //   } catch (e) {
// //     Navigator.pop(context); // Close dialog
// //     Navigator.pop(context, ApplyCouponResponse(
// //       success: false,
// //       discountAmount: 0,
// //       finalTotal: widget.orderTotal ?? 0,
// //       message: "Failed to apply coupon: ${e.toString().replaceAll('Exception:', '')}",
// //       couponCode: null,
// //     ));
// //   }
// // }
// // In your _applyCoupon method in CouponsSelectionScreen
// Future<void> _applyCoupon(String couponCode) async {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => const Center(
//       child: CircularProgressIndicator(),
//     ),
//   );

//   try {
//     final response = await _couponService.applyCoupon(
//       couponCode, 
//       widget.orderTotal ?? 0.0
//     );
    
//     Navigator.pop(context); // Close dialog
    
//     print('📨 Coupon response from service: ${response.success}, message: ${response.message}');
    
//     if (response.success) {
//       // IMPORTANT: Create response with coupon code
//       final successResponse = ApplyCouponResponse(
//         success: true,
//         discountAmount: response.discountAmount,
//         finalTotal: response.finalTotal,
//         message: response.message,
//         couponCode: couponCode, // Make sure this is set!
//       );
      
//       print('✅ Returning success response with coupon code: $couponCode');
//       Navigator.pop(context, successResponse);
//     } else {
//       print('❌ Returning error response');
//       Navigator.pop(context, response);
//     }
//   } catch (e) {
//     Navigator.pop(context); // Close dialog
//     print('❌ Exception in apply coupon: $e');
//     Navigator.pop(context, ApplyCouponResponse(
//       success: false,
//       discountAmount: 0,
//       finalTotal: widget.orderTotal ?? 0,
//       message: "Failed to apply coupon: ${e.toString().replaceAll('Exception:', '')}",
//       couponCode: null,
//     ));
//   }
// }

//   Future<void> _applyEnteredCoupon() async {
//     if (_couponController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter a coupon code"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     await _applyCoupon(_couponController.text.trim());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.greyWhiteColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryOrangeColor,
//         elevation: 0,
//         leadingWidth: 25,
//         automaticallyImplyLeading: true,
//         title: const Text(
//           "Available Coupons",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 38,
//                     child: TextField(
//                       controller: _couponController,
//                       style: const TextStyle(fontSize: 15),
//                       decoration: InputDecoration(
//                         hintText: "Enter coupon code",
//                         hintStyle: TextStyle(
//                           color: Colors.grey.shade500,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
//                         fillColor: Colors.white,
//                         filled: true,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
//                           borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
//                           borderSide: const BorderSide(color: Colors.green, width: 1.3),
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 38, 
//                   child: ElevatedButton(
//                     onPressed: _applyEnteredCoupon,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       minimumSize: const Size(0, 36),
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.horizontal(
//                           right: Radius.circular(10),
//                         ),
//                       ),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(horizontal: 18),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text(
//                       'Apply',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Best for you",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//                 letterSpacing: 0.3,
//               ),
//             ),
//             const SizedBox(height: 10),

//             Expanded(
//               child: _buildCouponsList(),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCouponsList() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: AppColors.primaryOrangeColor,
//         ),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.grey.shade600),
//             const SizedBox(height: 12),
//             Text(
//               _errorMessage!,
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _loadCoupons,
//               child: const Text("Retry"),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_coupons.isEmpty) {
//       return const Center(
//         child: Text("No coupons available"),
//       );
//     }

//     return ListView.separated(
//       itemCount: _coupons.length,
//       physics: const BouncingScrollPhysics(),
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final coupon = _coupons[index];
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 7, spreadRadius: 1, offset: const Offset(0, 2),
//               )
//             ],
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade100, width: 1),
//           ),
//           padding: const EdgeInsets.all(15),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Left: Coupon main info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       coupon.headline,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 7),
//                     // Coupon code
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryOrangeColor.withOpacity(0.09),
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                       child: Text(
//                         coupon.couponCode,
//                         style: const TextStyle(
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Discount info
//                     Text(
//                       _getDiscountText(coupon),
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade700,
//                         fontWeight: FontWeight.w500,
//                         height: 1.25,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Min. order: ₹${coupon.minOrderValue.toStringAsFixed(0)}",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                         height: 1.25,
//                       ),
//                     ),
//                     if (coupon.maxDiscount > 0 && coupon.discountType == 'percentage')
//                       Padding(
//                         padding: const EdgeInsets.only(top: 2),
//                         child: Text(
//                           "Max discount: ₹${coupon.maxDiscount.toStringAsFixed(0)}",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                             height: 1.25,
//                           ),
//                         ),
//                       ),
//                     if (coupon.expiryDate.isBefore(DateTime.now()))
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4),
//                         child: Text(
//                           "Expired on: ${_formatDate(coupon.expiryDate)}",
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.red,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ...coupon.dataPoints.map<Widget>((e) => Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Text(
//                         e,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade700,
//                           fontWeight: FontWeight.w400,
//                           height: 1.25,
//                         ),
//                       ),
//                     )),
//                   ],
//                 ),
//               ),
//               // Apply button
//               Align(
//                 alignment: Alignment.topRight,
//                 child: ElevatedButton(
//                   onPressed: coupon.isActive ? () => _applyCoupon(coupon.couponCode) : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: coupon.isActive ? Colors.green : Colors.grey,
//                     minimumSize: const Size(80, 35),
//                     padding: const EdgeInsets.symmetric(horizontal: 0),
//                     elevation: 0,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                   ),
//                   child: Text(
//                     coupon.isActive ? "Apply" : "Expired",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _getDiscountText(Coupon coupon) {
//     if (coupon.discountType == 'flat') {
//       return "₹${coupon.discountValue.toStringAsFixed(0)} OFF";
//     } else {
//       return "${coupon.discountValue.toStringAsFixed(0)} OFF";
//     }
//   }

//   String _formatDate(DateTime date) {
//     return "${date.day}/${date.month}/${date.year}";
//   }
// }
