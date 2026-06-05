
import 'dart:convert';
import 'package:e_commerce/Models/home_product.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:http/http.dart' as http;

class HomeService {
  final String baseUrl = 'https://grocerrybackend.onrender.com';

  Future<Map<String, List<Product>>> getHomeProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/public/products'), 
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data$data");
        print("response121$response");
        print("response.statusCode121${response.statusCode}");
        List<Category> categories = (data['data'] as List)
            .map((item) => Category.fromJson(item))
            .toList();

        Map<String, List<Product>> productsBySection = {};

        if (categories.isNotEmpty && categories[0].subcategories.isNotEmpty) {
          productsBySection['category'] = 
              categories[0].subcategories[0].products
                  .where((p) => p.status == 'active')
                  .toList();
        }

        if (categories.length > 1 && categories[1].subcategories.isNotEmpty) {
          productsBySection['category4'] = 
              categories[1].subcategories[0].products
                  .where((p) => p.status == 'active')
                  .toList();
        }

        if (categories.length > 2 && categories[2].subcategories.isNotEmpty) {
          productsBySection['category2'] = 
              categories[2].subcategories[0].products
                  .where((p) => p.status == 'active')
                  .toList();
        }

        if (categories.length > 3 && categories[3].subcategories.isNotEmpty) {
          productsBySection['category6'] = 
              categories[3].subcategories[0].products
                  .where((p) => p.status == 'active')
                  .toList();
        }

        return productsBySection;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching home products: $e');
      return {
        'fruitsVegetables': [],
        'personalCare': [],
        'dairy': [],
        'snacks': [],
      };
    }
  }

  // Get all products from all categories (flat list)
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/public/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Product> allProducts = [];

        List<Category> categories = (data['data'] as List)
            .map((item) => Category.fromJson(item))
            .toList();

        for (var category in categories) {
          for (var subcategory in category.subcategories) {
            allProducts.addAll(
              subcategory.products.where((p) => p.status == 'active'),
            );
          }
        }

        return allProducts;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching all products: $e');
      return [];
    }
  }
}