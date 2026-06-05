import 'package:flutter/material.dart';

class CouponProvider extends ChangeNotifier {
  bool isCouponApplied = false;
  String? appliedCouponCode;
  double discountAmount = 0.0;
  double? originalTotal;
  double? finalTotal;

  void applyCoupon({
    required String couponCode,
    required double discountAmount,
    required double orderTotal,
  }) {
    print('🎫 Applying coupon in provider: $couponCode');
    print('💰 Discount amount: $discountAmount');
    
    isCouponApplied = true;
    appliedCouponCode = couponCode;
    this.discountAmount = discountAmount;
    originalTotal = orderTotal;
    finalTotal = orderTotal - discountAmount;
    
    print('✅ Provider updated - isCouponApplied: $isCouponApplied, appliedCouponCode: $appliedCouponCode');
    notifyListeners();
  }

  void removeCoupon() {
    print('🗑️ Removing coupon');
    isCouponApplied = false;
    appliedCouponCode = null;
    discountAmount = 0.0;
    originalTotal = null;
    finalTotal = null;
    notifyListeners();
  }
}
