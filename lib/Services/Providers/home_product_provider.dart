// // Services/Providers/home_product_provider.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../Models/home_product.dart';

// class HomeProvider with ChangeNotifier {
//   final List<Product> _allProducts = [];
  
//   bool _isLoading = false;
//   String? _error;

//   // Getters
//   List<Product> get allProducts => _allProducts;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // Cart quantities
//   final Map<String, int> _cartQuantities = {};

//   // ==========================================
//   // QUANTITY MANAGEMENT
//   // ==========================================
  
//   int getQuantity(String productId) => _cartQuantities[productId] ?? 0;

//   void incrementQuantity(String productId) {
//     _cartQuantities[productId] = (_cartQuantities[productId] ?? 0) + 1;
//     debugPrint("🛒 Cart updated: $_cartQuantities");
//     notifyListeners();
//   }

//   void decrementQuantity(String productId) {
//     final currentQty = _cartQuantities[productId] ?? 0;
//     if (currentQty > 0) {
//       if (currentQty == 1) {
//         _cartQuantities.remove(productId);
//         debugPrint("🗑️ Removed from cart: $productId");
//       } else {
//         _cartQuantities[productId] = currentQty - 1;
//         debugPrint("➖ Decreased quantity: $productId = ${currentQty - 1}");
//       }
//       notifyListeners();
//     }
//   }

//   void updateQuantity(String productId, int quantity) {
//     if (quantity <= 0) {
//       _cartQuantities.remove(productId);
//       debugPrint("🗑️ Removed from cart: $productId");
//     } else {
//       _cartQuantities[productId] = quantity;
//       debugPrint("🔄 Updated quantity: $productId = $quantity");
//     }
//     notifyListeners();
//   }

//   void removeFromCart(String productId) {
//     _cartQuantities.remove(productId);
//     debugPrint("🗑️ Removed from cart: $productId");
//     notifyListeners();
//   }

//   // ==========================================
//   // CART INFORMATION
//   // ==========================================

//   bool isInCart(String productId) {
//     return _cartQuantities.containsKey(productId) && _cartQuantities[productId]! > 0;
//   }

//   int get totalCartItems {
//     final total = _cartQuantities.values.fold(0, (sum, qty) => sum + qty);
//     debugPrint("🔢 Total cart items: $total");
//     return total;
//   }

//   double get totalCartPrice {
//     double total = 0.0;
//     _cartQuantities.forEach((productId, quantity) {
//       final product = getProductById(productId);
//       if (product != null) {
//         total += product.salePrice * quantity;
//       }
//     });
//     debugPrint("💰 Total cart price: ₹$total");
//     return total;
//   }

//   bool get hasItems => _cartQuantities.isNotEmpty;

//   // Get list of cart items with product details
//   List<CartItemData> getCartItems() {
//     debugPrint("🔍 Getting cart items...");
//     debugPrint("📦 Products available: ${_allProducts.length}");
//     debugPrint("🛒 Cart quantities: $_cartQuantities");
    
//     final items = _cartQuantities.entries
//         .map((entry) {
//           final product = getProductById(entry.key);
//           if (product == null) {
//             debugPrint("⚠️ Product not found for ID: ${entry.key}");
//             return null;
//           }

//           debugPrint("✅ Found product: ${product.name} x ${entry.value}");
//           return CartItemData(
//             product: product,
//             quantity: entry.value,
//           );
//         })
//         .whereType<CartItemData>()
//         .toList();
    
//     debugPrint("📋 Total cart items: ${items.length}");
//     return items;
//   }

//   // ==========================================
//   // CART ACTIONS
//   // ==========================================

//   void clearCart() {
//     _cartQuantities.clear();
//     debugPrint("🗑️ Cart cleared");
//     notifyListeners();
//   }

//   void clearCartAfterOrder() {
//     _cartQuantities.clear();
//     debugPrint("✅ Cart cleared after order confirmation");
//     notifyListeners();
//   }

//   // ==========================================
//   // PRODUCT FETCHING
//   // ==========================================

//   Future<void> fetchHomeProducts() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       // Replace with your actual API URL
//       final response = await http.get(
//         Uri.parse('https://grocerrybackend.onrender.com/api/public/products'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
        
//         if (jsonData['success'] == true) {
//           List<dynamic> categories = jsonData['data'];
          
//           print('Total categories: ${categories.length}');

//           // Clear previous data
//           _allProducts.clear();

//           // Extract ALL products from ALL categories and subcategories
//           for (var category in categories) {
//             String categoryName = category['name'] ?? '';
//             print('Processing category: $categoryName');

//             if (category['subcategories'] != null) {
//               for (var subcategory in category['subcategories']) {
//                 if (subcategory['products'] != null) {
//                   List<Product> products = (subcategory['products'] as List)
//                       .map((p) => Product.fromJson(p))
//                       .where((p) => p.status == 'active')
//                       .toList();

//                   _allProducts.addAll(products);
//                   print('Added ${products.length} products from ${subcategory['name']}');
//                 }
//               }
//             }
//           }

//           print('Total products loaded: ${_allProducts.length}');

//           _isLoading = false;
//           notifyListeners();
//         } else {
//           throw Exception('API returned success: false');
//         }
//       } else {
//         throw Exception('Failed to load products: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in fetchHomeProducts: $e');
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ==========================================
//   // PRODUCT QUERIES
//   // ==========================================

//   Product? getProductById(String productId) {
//     try {
//       return _allProducts.firstWhere((p) => p.id == productId);
//     } catch (e) {
//       debugPrint("⚠️ Product not found: $productId");
//       return null;
//     }
//   }

//   // List<Product> getProductsByCategory(String category) {
//   //   return _allProducts.where((p) => p.category == category).toList();
//   // }

//   // List<Product> searchProducts(String query) {
//   //   final lowerQuery = query.toLowerCase();
//   //   return _allProducts.where((p) => 
//   //     p.name.toLowerCase().contains(lowerQuery) 
//   //     ||
//   //     p.category.toLowerCase().contains(lowerQuery)
//   //   ).toList();
//   // }
// }

// // ==========================================
// // CART ITEM DATA MODEL
// // ==========================================

// class CartItemData {
//   final Product product;
//   final int quantity;

//   CartItemData({
//     required this.product,
//     required this.quantity,
//   });

//   double get totalPrice => product.salePrice * quantity;
  
//   double get savings => (product.basePrice - product.salePrice) * quantity;
// }
