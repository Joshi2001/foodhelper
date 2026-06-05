// class DiscountRange {
//   final int min;
//   final int max;
//   final double discount;
//   final String rangeText;
//   final String priceText;
//   final String discountText;

//   DiscountRange({
//     required this.min,
//     required this.max,
//     required this.discount,
//     required this.rangeText,
//     required this.priceText,
//     required this.discountText,
//   });

//   /// Returns discount value - will be > 0 if there's a discount
//   double get discountPercent {
//     return discount > 0 ? discount : 0;
//   }
// factory DiscountRange.fromJson(Map<String, dynamic> json) {
//   final int minQty = json['minQty'] == null
//       ? 0
//       : (json['minQty'] as num).toInt();

//   final int maxQty = json['maxQty'] == null
//       ? -1 // -1 means unlimited
//       : (json['maxQty'] as num).toInt();

//   final double discountPercent = json['discountPercent'] == null
//       ? 0.0
//       : (json['discountPercent'] as num).toDouble();

//   return DiscountRange(
//     min: minQty,
//     max: maxQty,
//     discount: discountPercent,
//     rangeText: maxQty == -1 ? '$minQty+' : '$minQty - $maxQty',
//     discountText:
//         discountPercent > 0 ? '${discountPercent.toInt()}%' : 'No discount', priceText: '',
//   );
// }

//   // factory DiscountRange.fromJson(Map<String, dynamic> json) {
//   //   // Handle various possible field names from API
//   //   final int minQty = json['minQuantity'] ?? json['min'] ?? json['minimum'] ?? 0;
//   //   final int maxQty = json['maxQuantity'] ?? json['max'] ?? json['maximum'] ?? -1;
//   //   final double discountValue = 
//   //       (json['discount'] ?? json['discountPercent'] ?? json['discountAmount'] ?? 0).toDouble();
    
//   //   final String range = json['rangeText'] ?? 
//   //       (maxQty == -1 ? '$minQty+' : '$minQty-$maxQty');
    
//   //   final String price = json['priceText'] ?? json['price'] ?? '₹0';
//   //   final String discountDisplay = json['discountText'] ?? 
//   //       (discountValue > 0 ? '${discountValue.toInt()}%' : 'No discount');

//   //   return DiscountRange(
//   //     min: minQty,
//   //     max: maxQty,
//   //     discount: discountValue,
//   //     rangeText: range,
//   //     priceText: price.toString(),
//   //     discountText: discountDisplay,
//   //   );
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       'minQuantity': min,
//       'maxQuantity': max,
//       'discount': discount,
//       'rangeText': rangeText,
//       'priceText': priceText,
//       'discountText': discountText,
//     };
//   }
// }
// // class DiscountRange {
// //   final int min;
// //   final int max;
// //   final double discountPercent;

// //   DiscountRange({
// //     required this.min,
// //     required this.max,
// //     required this.discountPercent,
// //   });

// //   factory DiscountRange.fromJson(Map<String, dynamic> json) {
// //     return DiscountRange(
// //       min: json['minQty'],
// //       max: json['maxQty'],
// //       discountPercent: (json['discountPercent'] as num).toDouble(),
// //     );
// //   }

// //   String get rangeText => max == -1 ? "$min+" : "$min - $max";
// //   String get discountText => "$discountPercent%";

// //   String priceText(double basePrice) {
// //     final discountedPrice = basePrice * (1 - discountPercent / 100);
// //     return "₹${discountedPrice.toStringAsFixed(0)}";
// //   }
// // }
