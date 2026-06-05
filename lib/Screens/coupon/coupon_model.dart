class Coupon {
  final String couponCode;
  final String headline;
  final String discountType; 
  final double discountValue;
  final double minOrderValue;
  final double maxDiscount;
  final DateTime expiryDate;
  final bool isActive;
  final List<String> dataPoints;

  Coupon({
    required this.couponCode,
    required this.headline,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.expiryDate,
    required this.isActive,
    required this.dataPoints,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      couponCode: json['couponCode'] ?? '',
      headline: json['headline'] ?? json['title'] ?? '',
      discountType: json['discountType'] ?? 'flat',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      maxDiscount: (json['maxDiscount'] ?? 0).toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate']) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      dataPoints: List<String>.from(json['dataPoints'] ?? []),
    );
  }
}

class ApplyCouponRequest {
  final String couponCode;
  final double orderTotal;

  ApplyCouponRequest({required this.couponCode, required this.orderTotal});

  Map<String, dynamic> toJson() => {
        'couponCode': couponCode,
        'orderTotal': orderTotal,
      };
}

class ApplyCouponResponse {
  final bool success;
  final double discountAmount;
  final double finalTotal;
  final String message;
  final String? couponCode;
  
  ApplyCouponResponse({
    required this.success,
    required this.discountAmount,
    required this.finalTotal,
    required this.message,
    this.couponCode,
  });
  
  factory ApplyCouponResponse.fromJson(Map<String, dynamic> json) {
    return ApplyCouponResponse(
      success: json['success'] ?? false,
      discountAmount: (json['discount'] ?? 0).toDouble(), 
      finalTotal: (json['finalTotal'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      couponCode: json['couponCode'],
    );
  }
}

// class Coupon {
//   final String id;
//   final String headline;
//   final String couponCode;
//   final String discountType; 
//   final double discountValue;
//   final double minOrderValue;
//   final double maxDiscount;
//   final DateTime expiryDate;
//   final List<String> dataPoints;
//   final String status; 

//   Coupon({
//     required this.id,
//     required this.headline,
//     required this.couponCode,
//     required this.discountType,
//     required this.discountValue,
//     required this.minOrderValue,
//     required this.maxDiscount,
//     required this.expiryDate,
//     required this.dataPoints,
//     required this.status,
//   });

//   factory Coupon.fromJson(Map<String, dynamic> json) {
//     return Coupon(
//       id: json['_id'] ?? '',
//       headline: json['headline'] ?? '',
//       couponCode: json['couponCode'] ?? '',
//       discountType: json['discountType'] ?? 'flat',
//       discountValue: (json['discountValue'] ?? 0).toDouble(),
//       minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
//       maxDiscount: (json['maxDiscount'] ?? 0).toDouble(),
//       expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
//       dataPoints: List<String>.from(json['dataPoints'] ?? []),
//       status: json['status'] ?? 'active',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'headline': headline,
//       'couponCode': couponCode,
//       'discountType': discountType,
//       'discountValue': discountValue,
//       'minOrderValue': minOrderValue,
//       'maxDiscount': maxDiscount,
//       'expiryDate': expiryDate.toIso8601String(),
//       'dataPoints': dataPoints,
//       'status': status,
//     };
//   }

//   // Helper method to check if coupon is expired
//   bool get isExpired => expiryDate.isBefore(DateTime.now());
  
//   // Helper method to check if coupon is active
//   bool get isActive => status == 'active' && !isExpired;
  
//   // Calculate discount amount based on order total
//   double calculateDiscount(double orderTotal) {
//     if (!isActive || orderTotal < minOrderValue) return 0;
    
//     double discount = 0;
//     if (discountType == 'flat') {
//       discount = discountValue;
//     } else if (discountType == 'percentage') {
//       discount = (orderTotal * discountValue) / 100;
//     }
    
//     // Apply max discount limit
//     if (discount > maxDiscount) {
//       discount = maxDiscount;
//     }
    
//     return discount;
//   }
// }

// // Request model for apply coupon API
// class ApplyCouponRequest {
//   final String couponCode;
//   final double orderTotal;
  
//   ApplyCouponRequest({
//     required this.couponCode,
//     required this.orderTotal,
//   });
  
//   Map<String, dynamic> toJson() {
//     return {
//       'couponCode': couponCode,
//       'orderTotal': orderTotal,
//     };
//   }
// }

// // Response model for apply coupon API
// class ApplyCouponResponse {
//   final bool success;
//   final double discountAmount;
//   final double finalTotal;
//   final String message;
//   final Coupon? appliedCoupon;
  
//   ApplyCouponResponse({
//     required this.success,
//     required this.discountAmount,
//     required this.finalTotal,
//     required this.message,
//     this.appliedCoupon,
//   });
  
//   factory ApplyCouponResponse.fromJson(Map<String, dynamic> json) {
//     return ApplyCouponResponse(
//       success: json['success'] ?? false,
//       discountAmount: (json['discountAmount'] ?? 0).toDouble(),
//       finalTotal: (json['finalTotal'] ?? 0).toDouble(),
//       message: json['message'] ?? '',
//       appliedCoupon: json['appliedCoupon'] != null 
//           ? Coupon.fromJson(json['appliedCoupon']) 
//           : null,
//     );
//   }
// }
