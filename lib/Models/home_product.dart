// // models/product_model.dart
// class Product {
//   final String id;
//   final String name;
//   final Weight weight;
//   final double basePrice;
//   final double salePrice;
//   final String image;
//   final String status;

//   Product({
//     required this.id,
//     required this.name,
//     required this.weight,
//     required this.basePrice,
//     required this.salePrice,
//     required this.image,
//     required this.status,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//        id: json['_id'] ?? json['id'] ?? '',  // ✅ _id pehle check karo
//     name: json['name'] ?? '',
//       weight: Weight.fromJson(json['weight'] ?? {}),
//       basePrice: (json['basePrice'] ?? 0).toDouble(),
//       salePrice: (json['salePrice'] ?? 0).toDouble(),
//       image: json['image'] ?? '',
//       status: json['status'] ?? 'active',
//     );
//   }
// }

import 'package:e_commerce/Models/product.dart';

class Weight {
  final dynamic value;
  final String unit;

  Weight({required this.value, required this.unit});

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      value: json['value'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }

  @override
  String toString() => '$value$unit';
}

class Category {
  final String id;
  final String name;
  final String image;
  final List<SubCategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      subcategories: (json['subcategories'] as List?)
              ?.map((item) => SubCategory.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class SubCategory {
  final String? id;
  final String name;
  final String image;
  final List<Product> products;

  SubCategory({
    this.id,
    required this.name,
    required this.image,
    required this.products,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      products: (json['products'] as List?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
    );
  }
}