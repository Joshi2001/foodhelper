// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../Models/product.dart';
// import '../../Models/discount_range.dart';
// class SellerProductProvider with ChangeNotifier {
//   final ImagePicker _picker = ImagePicker();
//   File? _imageFile;
//   String _name = '';
//   String _weight = '';
//   double _originalPrice = 0.0;
//   double _currentPrice = 0.0;
//   String _category = '';
//   List<DiscountRange> _bulkPricing = [];

//   File? get imageFile => _imageFile;
//   String get name => _name;
//   String get weight => _weight;
//   double get originalPrice => _originalPrice;
//   double get currentPrice => _currentPrice;
//   String get category => _category;
//   List<DiscountRange> get bulkPricing => _bulkPricing;
//   bool get isValidForm {
//     return _name.isNotEmpty &&
//         _weight.isNotEmpty &&
//         _originalPrice > 0 &&
//         _currentPrice > 0 &&
//         _category.isNotEmpty;
//   }

//   // Setters
//   void setName(String value) {
//     _name = value;
//     notifyListeners();
//   }

//   void setWeight(String value) {
//     _weight = value;
//     notifyListeners();
//   }

//   void setOriginalPrice(String value) {
//     _originalPrice = double.tryParse(value) ?? 0.0;
//     notifyListeners();
//   }

//   void setCurrentPrice(String value) {
//     _currentPrice = double.tryParse(value) ?? 0.0;
//     notifyListeners();
//   }

//   void setCategory(String value) {
//     _category = value;
//     notifyListeners();
//   }

//   // Image picker
//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//     }
//   }

//   // Bulk pricing management
//   void addBulkRange(DiscountRange range) {
//     _bulkPricing.add(range);
//     // Sort by min quantity
//     _bulkPricing.sort((a, b) => a.min.compareTo(b.min));
//     notifyListeners();
//   }

//   void removeBulkRange(int index) {
//     if (index >= 0 && index < _bulkPricing.length) {
//       _bulkPricing.removeAt(index);
//       notifyListeners();
//     }
//   }

//   void updateBulkRange(int index, DiscountRange range) {
//     if (index >= 0 && index < _bulkPricing.length) {
//       _bulkPricing[index] = range;
//       _bulkPricing.sort((a, b) => a.min.compareTo(b.min));
//       notifyListeners();
//     }
//   }

//   void clearBulkPricing() {
//     _bulkPricing.clear();
//     notifyListeners();
//   }

//   // Convert to Product object
//   Product toProduct(String id, {String? imagePath}) {
//     return Product(
//       id: id,
//       name: _name,
//       weight: _weight,
//       imagePath: imagePath ?? _imageFile?.path ?? '',
//       originalPrice: _originalPrice,
//       currentPrice: _currentPrice,
//       category: _category,
//       bulkPricing: List<DiscountRange>.from(_bulkPricing),
//     );
//   }

//   // Load existing product for editing
//   void loadProduct(Product product) {
//     _name = product.name;
//     _weight = product.weight;
//     _originalPrice = product.originalPrice;
//     _currentPrice = product.currentPrice;
//     _category = product.category;
//     _bulkPricing = List<DiscountRange>.from(product.bulkPricing);

//     if (product.imagePath.isNotEmpty) {
//       _imageFile = File(product.imagePath);
//     }

//     notifyListeners();
//   }

//   // Reset/clear form
//   void resetForm() {
//     _imageFile = null;
//     _name = '';
//     _weight = '';
//     _originalPrice = 0.0;
//     _currentPrice = 0.0;
//     _category = '';
//     _bulkPricing.clear();
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     // Clean up if needed
//     super.dispose();
//   }
// }
