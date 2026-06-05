import 'package:flutter/material.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final double originalTotalPrice;
  final double totalPrice;
  final double couponDiscount;
  final String? couponCode;
  final double finalPrice;
  final String status;
  final DateTime orderDate;
  final Map<String, dynamic>? address;
  final String paymentMode;
  final String paymentStatus;
  final double deliveryCharge;
  final double handlingCharge;

  Order({
    required this.id,
    required this.items,
    required this.originalTotalPrice,
    required this.totalPrice,
    required this.couponDiscount,
    this.couponCode,
    required this.finalPrice,
    required this.status,
    required this.orderDate,
    this.address,
    required this.paymentMode,
    required this.paymentStatus,
    this.deliveryCharge = 0.0,
    this.handlingCharge = 0.0,
  });

  static double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
  final List<dynamic> itemsData = json['items'] ?? [];
  final List<OrderItem> parsedItems = [];

  for (var itemData in itemsData) {
    try {
      parsedItems.add(OrderItem.fromJson(itemData as Map<String, dynamic>));
    } catch (e) {
      debugPrint('⚠️ Failed to parse item: $e');
    }
  }

  // FIRST: Calculate total from items if needed
  double calculatedTotalFromItems = 0.0;
  for (var item in parsedItems) {
    calculatedTotalFromItems += item.totalPrice;
  }

  // Get values with proper fallbacks
  final double originalTotal = _toDouble(
    json['originalTotalPrice'] ?? json['totalPrice'],
  );

  // Try to get totalPrice from API, then from items calculation
  double totalPriceValue = _toDouble(json['totalPrice']);
  if (totalPriceValue <= 0 && calculatedTotalFromItems > 0) {
    totalPriceValue = calculatedTotalFromItems;
    debugPrint("💰 totalPrice calculated from items: $totalPriceValue");
  }
  if (totalPriceValue <= 0) {
    totalPriceValue = originalTotal;
  }

  final double deliveryChargeValue = _toDouble(json['deliveryCharge']);
  final double handlingChargeValue = _toDouble(json['handlingCharge']);
  final double couponDiscountValue = _toDouble(json['couponDiscount']);
  
  // Get finalPrice from API
  double finalPriceValue = _toDouble(json['finalPrice']);
  
  final bool hasCoupon = json['couponCode'] != null && 
                         json['couponCode'].toString().isNotEmpty && 
                         couponDiscountValue > 0;
  
  // If finalPrice is 0 or missing, ALWAYS recalculate from components
  if (finalPriceValue <= 0) {
    finalPriceValue = totalPriceValue + deliveryChargeValue + handlingChargeValue - couponDiscountValue;
    debugPrint("💰 Recalculated finalPrice: $totalPriceValue + $deliveryChargeValue + $handlingChargeValue - $couponDiscountValue = $finalPriceValue");
  }
  
  // Additional validation: If finalPrice is less than totalPrice but no coupon, use totalPrice
  if (!hasCoupon && finalPriceValue < totalPriceValue && totalPriceValue > 0) {
    debugPrint("⚠️ Warning: No coupon but finalPrice ($finalPriceValue) < totalPrice ($totalPriceValue). Using totalPrice.");
    finalPriceValue = totalPriceValue + deliveryChargeValue + handlingChargeValue;
  }

  final String? couponCodeValue =
      (json['couponCode'] != null && json['couponCode'].toString().isNotEmpty)
          ? json['couponCode'].toString()
          : null;

  DateTime orderDate;
  try {
    orderDate = DateTime.parse(
      json['createdAt']?.toString() ??
          json['orderDate']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  } catch (_) {
    orderDate = DateTime.now();
  }

  debugPrint("📊 ORDER PARSING SUMMARY:");
  debugPrint("   totalPrice: $totalPriceValue");
  debugPrint("   deliveryCharge: $deliveryChargeValue");
  debugPrint("   handlingCharge: $handlingChargeValue");
  debugPrint("   couponDiscount: $couponDiscountValue");
  debugPrint("   hasCoupon: $hasCoupon");
  debugPrint("   finalPrice from API: ${json['finalPrice']}");
  debugPrint("   finalPrice used: $finalPriceValue");

  return Order(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    items: parsedItems,
    originalTotalPrice: originalTotal > 0 ? originalTotal : totalPriceValue,
    totalPrice: totalPriceValue,
    couponDiscount: couponDiscountValue,
    couponCode: couponCodeValue,
    finalPrice: finalPriceValue,
    status: json['status']?.toString() ?? 'placed',
    orderDate: orderDate,
    address: json['address'] as Map<String, dynamic>?,
    paymentMode: json['paymentMode']?.toString() ?? 'cod',
    paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
    deliveryCharge: deliveryChargeValue,
    handlingCharge: handlingChargeValue,
  );
}

  bool get hasCoupon => couponCode != null && couponDiscount > 0;
  int get itemCount => items.length;

  String get displaySummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} + ${items.length - 1} more';
  }

  String get displayImage {
    if (items.isNotEmpty && items.first.productImage.isNotEmpty) {
      return items.first.productImage;
    }
    return '';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'placed':
        return const Color(0xFFFF9800);
      case 'confirmed':
        return const Color(0xFF2196F3);
      case 'shipped':
      case 'out_for_delivery':
        return const Color(0xFF9C27B0);
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.receipt_long;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'shipped':
      case 'out_for_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'placed':
        return 'Order Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final String type;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productDetails = json['productDetails'] as Map<String, dynamic>?;

    final String productName = productDetails?['name']?.toString() ??
        json['name']?.toString() ??
        json['productName']?.toString() ??
        'Product';

    final String productImage = productDetails?['imagePath']?.toString() ??
        productDetails?['image']?.toString() ??
        json['image']?.toString() ??
        json['productImage']?.toString() ??
        '';

    final int quantity = (json['quantity'] as num?)?.toInt() ?? 1;
    final double unitPrice = _toDouble(json['unitPrice']);
    final double totalPrice = _toDouble(
      json['price'] ?? json['totalPrice'],
      quantity * unitPrice,
    );

    return OrderItem(
      productId:
          json['product']?.toString() ?? json['productId']?.toString() ?? '',
      productName: productName,
      productImage: productImage,
      type:
          json['ownerType']?.toString() ?? json['type']?.toString() ?? 'vendor',
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  static double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }
}
