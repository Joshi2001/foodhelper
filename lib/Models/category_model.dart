// import 'package:e_commerce/Models/product.dart';

// class Category {
//   final String id;
//   final String name;
//   final String? image;
//   final List<SubCategory>? subcategories;

//   Category({
//     required this.id,
//     required this.name,
//     this.image,
//     this.subcategories,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       image: json['image'],
//       subcategories: json['subcategories'] != null
//           ? (json['subcategories'] as List)
//               .map((v) => SubCategory.fromJson(v))
//               .toList()
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'image': image,
//       'subcategories': subcategories?.map((v) => v.toJson()).toList(),
//     };
//   }

//   @override
//   String toString() => 'Category(id: $id, name: $name)';
// }

// // SubCategory Model
// class SubCategory {
//   final String? id;
//   final String name;
//   final String? image;
//   final List<Product>? products;

//   SubCategory({
//     this.id,
//     required this.name,
//     this.image,
//     this.products,
//   });

//   factory SubCategory.fromJson(Map<String, dynamic> json) {
//     return SubCategory(
//       id: json['id'],
//       name: json['name'] ?? '',
//       image: json['image'],
//       products: json['products'] != null
//           ? (json['products'] as List)
//               .map((v) => Product.fromJson(v))
//               .toList()
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'image': image,
//       'products': products?.map((v) => v.toJson()).toList(),
//     };
//   }

//   @override
//   String toString() => 'SubCategory(id: $id, name: $name)';
// }
import 'package:e_commerce/Models/product.dart';

class Category {
  final String id;
  final String name;
  final String? image;
  final List<SubCategory>? subcategories;

  Category({
    required this.id,
    required this.name,
    this.image,
    this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: _extractString(json['id'], 'id'),
        name: _extractString(json['name'], 'name'),
        image: json['image']?.toString().trim(),
        subcategories: json['subcategories'] != null && json['subcategories'] is List
            ? (json['subcategories'] as List<dynamic>)
                .map((v) {
                  if (v is Map<String, dynamic>) {
                    return SubCategory.fromJson(v);
                  }
                  return null;
                })
                .whereType<SubCategory>()
                .toList()
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Category: $e, json: $json');
      rethrow;
    }
  }

  // Helper method to safely extract strings
  static String _extractString(dynamic value, String fieldName) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is int) return value.toString();
    if (value is Map) {
      // If it's a Map, try to get 'name' or 'title' property
      final extracted = (value['name'] ?? value['title'] ?? value['id'] ?? '').toString();
      return extracted.trim();
    }
    return value.toString().trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'subcategories': subcategories?.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';
}

// SubCategory Model
class SubCategory {
  final String? id;
  final String name;
  final String? image;
  final List<Product>? products;

  SubCategory({
    this.id,
    required this.name,
    this.image,
    this.products,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    try {
      return SubCategory(
        id: json['id']?.toString().trim(),
        name: (json['name'] ?? '').toString().trim(),
        image: json['image']?.toString().trim(),
        products: json['products'] != null && json['products'] is List
            ? (json['products'] as List<dynamic>)
                .map((v) {
                  if (v is Map<String, dynamic>) {
                    return Product.fromJson(v);
                  }
                  return null;
                })
                .whereType<Product>()
                .toList()
            : null,
      );
    } catch (e) {
      print('❌ Error parsing SubCategory: $e, json: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'products': products?.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() => 'SubCategory(id: $id, name: $name)';
}