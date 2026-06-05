// class SubCategory {
//   final String id;
//   final String name;
//   final String category;
//   final String? image;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   SubCategory({
//     required this.id,
//     required this.name,
//     required this.category,
//     this.image,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory SubCategory.fromJson(Map<String, dynamic> json) {
//     return SubCategory(
//       id: json['_id'] ?? json['id'] ?? '',
//       name: json['name'] ?? '',
//       category: json['category'] ?? '',
//       image: json['image'],
//       createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
//       updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'category': category,
//       'image': image,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }

//   @override
//   String toString() => 'SubCategory(id: $id, name: $name, category: $category)';
// }