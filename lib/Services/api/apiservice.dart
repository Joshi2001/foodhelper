import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/Models/cart_item.dart';
import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MaintenanceException implements Exception {
  final String message;
  MaintenanceException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client httpClient;

  ApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  void _checkMaintenance(Map<String, dynamic> decoded) {
    if (decoded['maintenance'] == true) {
      throw MaintenanceException(
        decoded['message'] ?? 'We are under maintenance',
      );
    }
  }

  Future<Map<String, dynamic>> getProductsPaged({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products?page=$page&limit=$limit'))
          .timeout(const Duration(seconds: 15));

      debugPrint("📥 getProductsPaged page=$page status=${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      _checkMaintenance(decoded); 

      final List rawList = decoded['data'] ?? [];
      final int totalPages = decoded['pages'] ?? 1;

      final products = rawList
          .map((item) {
            try {
              return Product.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint("⚠️ Parse error: $e");
              return null;
            }
          })
          .whereType<Product>()
          .toList();

      return {'products': products, 'pages': totalPages};
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e, stack) {
      debugPrint("❌ getProductsPaged: $e\n$stack");
      throw Exception('Failed: $e');
    }
  }

  Future<Product> getProductById(String productId) async {
    final response = await httpClient
        .get(Uri.parse('$baseUrl/api/public/products?limit=200'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw Exception('Failed');

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    _checkMaintenance(decoded); // ✅

    final List rawList = decoded['data'] ?? [];

    final productJson = rawList.firstWhere(
      (item) => item['_id'] == productId || item['id'] == productId,
      orElse: () => null,
    );

    if (productJson == null) throw Exception('Product not found: $productId');
    return Product.fromJson(productJson as Map<String, dynamic>);
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          _checkMaintenance(decoded); // ✅
        }

        List<dynamic> list = [];
        if (decoded is Map) {
          if (decoded['data'] is List) {
            list = decoded['data'];
          } else if (decoded['categories'] is List) {
            list = decoded['categories'];
          }
        } else if (decoded is List) {
          list = decoded;
        }

        return list
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed with status ${response.statusCode}');
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e, stack) {
      debugPrint('❌ Error in getCategories: $e\n$stack');
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products?category=$category'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        _checkMaintenance(decoded); // ✅

        final List<dynamic> list =
            decoded['data'] is List ? decoded['data'] : [];

        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 404) throw Exception('Products not found (404)');
      if (response.statusCode == 500) throw Exception('Server error. Please try again later.');
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<Product>> getProductsBySubCategory(String subCategory) async {
    final url = Uri.parse('$baseUrl/api/public/products?subcategory=$subCategory');
    final response = await http.get(url);

    debugPrint("📥 Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        _checkMaintenance(decoded); // ✅
        if (decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        }
      }

      if (decoded is List) {
        return decoded.map((e) => Product.fromJson(e)).toList();
      }

      throw Exception("Invalid product response format");
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<Product> getSubPro(String productId) async {
    final url = Uri.parse('$baseUrl/api/public/products');
    final response = await http.get(url);

    if (response.statusCode != 200) throw Exception('Failed to fetch products');
    if (response.body.isEmpty || response.body == 'null') throw Exception('Empty response');

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) throw Exception('Invalid response format');

    _checkMaintenance(decoded); // ✅

    final List data = decoded['data'];
    final productJson = data.firstWhere(
      (item) => item['_id'] == productId || item['id'] == productId,
      orElse: () => null,
    );

    if (productJson == null) throw Exception('Product not found');
    return Product.fromJson(productJson);
  }

  Future<List<SubCategory>> getSubCategories(String category) async {
    try {
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/api/public/products?category=$category'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          _checkMaintenance(decoded); // ✅
        }

        List<dynamic> list = [];
        if (decoded is Map) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            list = decoded['data'] as List<dynamic>;
          } else if (decoded.containsKey('subcategories') && decoded['subcategories'] is List) {
            list = decoded['subcategories'] as List<dynamic>;
          }
        } else if (decoded is List) {
          list = decoded;
        }

        if (list.isEmpty) throw Exception('No subcategories found for category: $category');

        return list
            .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception('Subcategories not found (404)');
      } else if (response.statusCode == 500) {
        throw Exception('Server error (500).');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e, stack) {
      debugPrint('❌ Error in getSubCategories: $e\n$stack');
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  Future<CartItem> addToCart(String userId, String productId, int quantity) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/public/products?cart/$userId/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CartItem.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error.');
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<List<Category>> fetchAllCategories() async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products?limit=200'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        _checkMaintenance(decoded); // ✅

        final List products = decoded['data'] ?? [];
        final Map<String, Category> uniqueCategories = {};

        for (var product in products) {
          if (product['category'] != null && product['category'] is Map) {
            final catData = product['category'] as Map;
            final catId = catData['_id']?.toString();
            if (catId != null && catId.isNotEmpty && !uniqueCategories.containsKey(catId)) {
              uniqueCategories[catId] = Category(
                id: catId,
                name: catData['name']?.toString() ?? '',
                image: catData['image']?.toString() ?? '',
                subcategories: [],
              );
            }
          }
        }

        debugPrint("✅ Extracted ${uniqueCategories.length} unique categories");
        return uniqueCategories.values.toList();
      }

      throw Exception('Failed: ${response.statusCode}');
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<void> updateCartItem(String userId, String cartItemId, int quantity) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl/api/public/products?cart/$userId/items/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/public/products?cart/$userId/items/$cartItemId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/cart/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products?limit=200'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) throw Exception('Failed');

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      _checkMaintenance(decoded); // ✅

      final List rawList = decoded['data'] ?? [];
      final List<Product> products = [];

      for (var item in rawList) {
        try {
          products.add(Product.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          debugPrint("⚠️ Parse error: $e");
        }
      }

      debugPrint("✅ Total products: ${products.length}");
      return products;
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e) {
      throw Exception('Failed: $e');
    }
  }

  Future<Map<String, dynamic>> getAllSubcategoriesWithProducts() async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/public/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) throw Exception('Failed to fetch data');

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) throw Exception('Invalid response format');

      _checkMaintenance(decoded); // ✅

      final List categories = decoded['data'] ?? [];
      final Map<String, List<Product>> subcategoryProducts = {};

      for (var category in categories) {
        final List subcategories = category['subcategories'] ?? [];
        for (var subcategory in subcategories) {
          final String subcategoryName = subcategory['name'] ?? 'Unknown';
          final List products = subcategory['products'] ?? [];
          List<Product> productList = [];
          for (var productJson in products) {
            try {
              productList.add(Product.fromJson(productJson));
            } catch (e) {
              debugPrint("⚠️ Failed to parse product: $e");
            }
          }
          if (productList.isNotEmpty) {
            subcategoryProducts[subcategoryName] = productList;
          }
        }
      }

      return {'subcategoryProducts': subcategoryProducts};
    } on MaintenanceException {
      rethrow;
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timeout.');
    } catch (e, stack) {
      debugPrint("❌ Error in getAllSubcategoriesWithProducts: $e\n$stack");
      throw Exception('Failed to load data: $e');
    }
  }
}
