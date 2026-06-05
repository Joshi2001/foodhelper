// import 'package:flutter/material.dart';
// import '../../Models/cart_item.dart';

// class CartProvider extends ChangeNotifier {
//   List<CartItem> _cartItems = [];
//   final String _deliveryTime = "28 minutes";
//   final double _deliveryCharges = 49.0;
//   final double _packagingCharges = 25.0;
//   double _couponDiscount = 0.0;
//   List<CartItem> get cartItems => _cartItems;
//   String get deliveryTime => _deliveryTime;
//   int get totalItemsCount =>
//       _cartItems.fold(0, (sum, item) => sum + item.quantity);

//   double get subtotal =>
//       _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

//   double get deliveryCharges => _deliveryCharges;
//   double get packagingCharges => _packagingCharges;
//   double get gstCharges => subtotal * 0.18;
//   double get couponDiscount => _couponDiscount;

//   double get bulkDiscount {
//     return _cartItems.fold(0.0, (sum, item) => sum + item.totalDiscount);
//   }

//   double get grandTotal =>
//       subtotal +
//           deliveryCharges +
//           packagingCharges +
//           gstCharges -
//           couponDiscount -
//           bulkDiscount;

//   List<Map<String, dynamic>> get billDetails {
//     List<Map<String, dynamic>> details = [
//       {"title": "Subtotal", "amount": subtotal},
//       {"title": "Delivery Charges", "amount": deliveryCharges},
//       {"title": "Packaging Charges", "amount": packagingCharges},
//       {"title": "GST (18%)", "amount": gstCharges},
//     ];

//     if (couponDiscount > 0) {
//       details.add({"title": "Coupon Discount", "amount": -couponDiscount});
//     }

//     if (bulkDiscount > 0) {
//       details.add({"title": "Bulk Discount", "amount": -bulkDiscount});
//     }

//     return details;
//   }

//   void loadCartFromHome(List<CartItem> items) {
//     _cartItems = List.from(items);
//     notifyListeners();
//   }

//   void updateQuantity(String productId, int newQuantity) {
//     final itemIndex =
//     _cartItems.indexWhere((item) => item.product.id == productId);
//     if (itemIndex != -1) {
//       if (newQuantity > 0) {
//         _cartItems[itemIndex].quantity = newQuantity;
//         notifyListeners();
//       } else {
//         removeItem(productId);
//       }
//     }
//   }

//   void increaseQuantity(String productId) {
//     final itemIndex =
//     _cartItems.indexWhere((item) => item.product.id == productId);
//     if (itemIndex != -1) {
//       _cartItems[itemIndex].quantity++;
//       notifyListeners();
//     }
//   }

//   void decreaseQuantity(String productId) {
//     final itemIndex =
//     _cartItems.indexWhere((item) => item.product.id == productId);
//     if (itemIndex != -1) {
//       if (_cartItems[itemIndex].quantity > 1) {
//         _cartItems[itemIndex].quantity--;
//         notifyListeners();
//       } else {
//         removeItem(productId);
//       }
//     }
//   }

//   void removeItem(String productId) {
//     _cartItems.removeWhere((item) => item.product.id == productId);
//     notifyListeners();
//   }

//   void applyCoupon(double discountAmount) {
//     _couponDiscount = discountAmount;
//     notifyListeners();
//   }

//   void clearCart() {
//     _cartItems.clear();
//     _couponDiscount = 0.0;
//     notifyListeners();
//   }

//   String getCurrentTierInfo(String productId) {
//     try {
//       final item =
//       _cartItems.firstWhere((item) => item.product.id == productId);
//       int quantity = item.quantity;

//       for (var tier in item.product.bulkPricing.reversed) {
//         if (tier.isQuantityInRange(quantity)) {
//           if (tier.discount == 0) return "Regular";
//           if (tier.discount < 10) return "Bulk";
//           return "Wholesale";
//         }
//       }
//       return "Regular";
//     } catch (e) {
//       return "Regular";
//     }
//   }

//   CartItem? getCartItem(String productId) {
//     try {
//       return _cartItems.firstWhere((item) => item.product.id == productId);
//     } catch (e) {
//       return null;
//     }
//   }

//   bool isInCart(String productId) {
//     return _cartItems.any((item) => item.product.id == productId);
//   }

//   int getProductQuantity(String productId) {
//     try {
//       final item =
//       _cartItems.firstWhere((item) => item.product.id == productId);
//       return item.quantity;
//     } catch (e) {
//       return 0;
//     }
//   }
// }
