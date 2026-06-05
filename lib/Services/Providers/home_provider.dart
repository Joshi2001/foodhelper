// import 'package:flutter/material.dart';
// import '../../Models/discount_range.dart';
// import '../../Models/product.dart';
// import '../../Models/cart_item.dart';
// import 'cart_provider.dart';

// class HomeProvider extends ChangeNotifier {

//   List<Product> _products = [];
//   Map<String, int> _productQuantities = {};

//   List<Product> get products => _products;

//   HomeProvider() {
//     _initializeProducts();
//   }



//   void _initializeProducts() {
//     _products = [
//       Product(
//         id: "1",
//         name: "Atta, rice & Dals",
//         weight: "300gms",
//         imagePath: "Assets/Categories/1.png",
//         originalPrice: 120.0,
//         currentPrice: 100.0,
//         category: "Milk and Breads",
//         bulkPricing: [
//           DiscountRange(min: 1, max: 1, price: 110, discount: 0),
//           DiscountRange(min: 2, max: 11, price: 105, discount: 5),
//           DiscountRange(min: 12, max: 21, price: 100, discount: 10),
//           DiscountRange(min: 22, max: 31, price: 95, discount: 15),
//           DiscountRange(min: 32, max: 41, price: 90, discount: 20),
//           DiscountRange(min: 42, max: 50, price: 85, discount: 25),
//         ],
//       ),
//       Product(
//         id: "2",
//         name: "Breakfast,Dips & Spreads",
//         weight: "1L",
//         imagePath: "Assets/Categories/2.png",
//         originalPrice: 150.0,
//         currentPrice: 120.0,
//         category: "Milk and Breads",
//         bulkPricing: [
//           DiscountRange(min: 1, max: 1, price: 120, discount: 0),
//           DiscountRange(min: 2, max: 5, price: 115, discount: 5),
//           DiscountRange(min: 6, max: 10, price: 110, discount: 10),
//           DiscountRange(min: 11, max: -1, price: 100, discount: 20),
//         ],
//       ),
//       Product(
//         id: "3",
//         name: "Oil & Masala's",
//         weight: "500gm",
//         imagePath: "Assets/Categories/3.png",
//         originalPrice: 200.0,
//         currentPrice: 180.0,
//         category: "Personal Care",
//         bulkPricing: [
//           DiscountRange(min: 1, max: 1, price: 180, discount: 0),
//           DiscountRange(min: 2, max: 5, price: 175, discount: 5),
//           DiscountRange(min: 6, max: -1, price: 165, discount: 15),
//         ],
//       ),
//       Product(
//         id: "4",
//         name: "Biscuits, Namkeen & Chips",
//         weight: "400gm",
//         imagePath: "Assets/Categories/4.png",
//         originalPrice: 45.0,
//         currentPrice: 40.0,
//         category: "Milk and Breads",
//         bulkPricing: [
//           DiscountRange(min: 1, max: 3, price: 40, discount: 0),
//           DiscountRange(min: 4, max: 10, price: 38, discount: 2),
//           DiscountRange(min: 11, max: -1, price: 35, discount: 5),
//         ],
//       ),
//       Product(
//         id: "5",
//         name: "Hot & Cold Beverages",
//         weight: "1kg",
//         imagePath: "Assets/Categories/5.png",
//         originalPrice: 180.0,
//         currentPrice: 160.0,
//         category: "Personal Care",
//         bulkPricing: [
//           DiscountRange(min: 1, max: 2, price: 160, discount: 0),
//           DiscountRange(min: 3, max: 5, price: 155, discount: 5),
//           DiscountRange(min: 6, max: -1, price: 145, discount: 15),
//         ],
//       ),
//     ];

//     notifyListeners();
//   }

//   Product getProductByIndex(int index) {
//     if (index < _products.length) {
//       return _products[index];
//     }
//     return _products[0];
//   }

//   List<Product> getProductAll() {
//     // if (index < _products.length) {
//       return _products;

//     // return _products[0];
//   }

//   Product? getProductById(String id) {
//     try {
//       return _products.firstWhere((product) => product.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   List<Product> getProductsByCategory(String category) {
//     return _products.where((product) => product.category == category).toList();
//   }

//   int getQuantity(String productId) {
//     return _productQuantities[productId] ?? 0;
//   }

//   void updateQuantity(String productId, int quantity) {
//     if (quantity <= 0) {
//       _productQuantities.remove(productId);
//     } else {
//       _productQuantities[productId] = quantity;
//     }
//     notifyListeners();
//   }

//   void incrementQuantity(String productId) {
//     _productQuantities[productId] = (_productQuantities[productId] ?? 0) + 1;
//     notifyListeners();

//   }

//   void decrementQuantity(String productId) {
//     int currentQty = _productQuantities[productId] ?? 0;
//     if (currentQty > 0) {
//       if (currentQty == 1) {
//         _productQuantities.remove(productId);
//       } else {
//         _productQuantities[productId] = currentQty - 1;
//       }
//       notifyListeners();
//       // _cartProvider.loadCartFromHome(getCartItems());
//     }
//   }

//   int get totalCartItems {
//     return _productQuantities.values.fold(0, (sum, qty) => sum + qty);
//   }

//   List<CartItem> getCartItems() {
//     List<CartItem> cartItems = [];
//     _productQuantities.forEach((productId, quantity) {
//       Product? product = getProductById(productId);
//       if (product != null) {
//         cartItems.add(CartItem(product: product, quantity: quantity));
//       }
//     });
//     return cartItems;
//   }

//   void clearCart() {
//     _productQuantities.clear();
//     notifyListeners();
//   }
// }
