// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// import '../../Models/discount_range.dart';
// import '../../app_colors.dart';
// import '../Services/Providers/seller_product_provider.dart';

// class SellerAddProductScreen extends StatelessWidget {
//   final dynamic product; // Pass existing product for edit mode
//   final bool isEditMode;

//   const SellerAddProductScreen({
//     super.key,
//     this.product,
//     this.isEditMode = false,
//   });



//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => SellerProductProvider(),
//       child: _SellerAddProductBody(
//         product: product,
//         isEditMode: isEditMode,
//       ),
//     );
//   }
// }

// class _SellerAddProductBody extends StatefulWidget {
//   final dynamic product;
//   final bool isEditMode;

//   const _SellerAddProductBody({
//     super.key,
//     this.product,
//     required this.isEditMode,
//   });

//   @override
//   State<_SellerAddProductBody> createState() => _SellerAddProductBodyState();
// }



// class _SellerAddProductBodyState extends State<_SellerAddProductBody> {

//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _weightController;
//   late TextEditingController _originalPriceController;
//   late TextEditingController _currentPriceController;
//   late TextEditingController _categoryController;

//   // Controllers for bulk range input
//   final TextEditingController _minCtrl = TextEditingController();
//   final TextEditingController _maxCtrl = TextEditingController();
//   final TextEditingController _priceCtrl = TextEditingController();
//   final TextEditingController _discountCtrl = TextEditingController();

//   // ADD THIS: Weight unit dropdown
//   String _selectedUnit = 'kg'; // Default unit
//   final List<String> _units = ['kg', 'g', 'ltr', 'ml'];

//   @override
//   void initState() {
//     super.initState();

//     // Initialize controllers with existing data if in edit mode
//     _nameController = TextEditingController(
//       text: widget.isEditMode && widget.product != null
//           ? widget.product.name ?? ''
//           : '',
//     );
//     _weightController = TextEditingController(
//       text: widget.isEditMode && widget.product != null
//           ? widget.product.weight ?? ''
//           : '',
//     );
//     _originalPriceController = TextEditingController(
//       text: widget.isEditMode && widget.product != null
//           ? widget.product.originalPrice.toString()
//           : '',
//     );
//     _currentPriceController = TextEditingController(
//       text: widget.isEditMode && widget.product != null
//           ? widget.product.currentPrice.toString()
//           : '',
//     );
//     _categoryController = TextEditingController(
//       text: widget.isEditMode && widget.product != null
//           ? (widget.product.category ?? '')
//           : '',
//     );

//     // Pre-populate provider with existing data after first frame
//     if (widget.isEditMode && widget.product != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final provider = context.read<SellerProductProvider>();
//         provider.setName(widget.product.name ?? '');
//         provider.setWeight(widget.product.weight ?? '');
//         provider.setOriginalPrice(widget.product.originalPrice.toString());
//         provider.setCurrentPrice(widget.product.currentPrice.toString());
//         provider.setCategory(widget.product.category ?? '');

//         // Add existing bulk pricing ranges
//         if (widget.product.bulkPricing != null) {
//           for (var range in widget.product.bulkPricing) {
//             provider.addBulkRange(range);
//           }
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _weightController.dispose();
//     _originalPriceController.dispose();
//     _currentPriceController.dispose();
//     _categoryController.dispose();
//     _minCtrl.dispose();
//     _maxCtrl.dispose();
//     _priceCtrl.dispose();
//     _discountCtrl.dispose();
//     super.dispose();
//   }

//   InputDecoration buildInputDecoration(String labelText) {
//     return InputDecoration(
//       labelText: labelText,
//       border: OutlineInputBorder(
//         borderSide: BorderSide(color: AppColors.primaryIndigoColor.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: AppColors.primaryIndigoColor.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: AppColors.primaryIndigoColor.shade500),
//       ),
//     );
//   }

//   void _showImagePickerSheet(BuildContext context) {
//     final provider = context.read<SellerProductProvider>();
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: Icon(Icons.photo_library, color: AppColors.primaryIndigoColor),
//               title: const Text('Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 provider.pickImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.photo_camera, color: AppColors.primaryIndigoColor),
//               title: const Text('Camera'),
//               onTap: () {
//                 Navigator.pop(context);
//                 provider.pickImage(ImageSource.camera);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addBulkRange(BuildContext context) {
//     final provider = context.read<SellerProductProvider>();
//     final min = int.tryParse(_minCtrl.text);
//     final max = int.tryParse(_maxCtrl.text);
//     final price = double.tryParse(_priceCtrl.text);
//     final discount = double.tryParse(_discountCtrl.text);


//     if (min == null || price == null || discount == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Fill min, price and discount correctly')),
//       );
//       return;
//     }


//     provider.addBulkRange(
//       DiscountRange(
//         min: min,
//         max: max ?? -1,
//         price: price,
//         discount: discount,
//       ),
//     );

//     _minCtrl.clear();
//     _maxCtrl.clear();
//     _priceCtrl.clear();
//     _discountCtrl.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SellerProductProvider>();
//     return Scaffold(

//       backgroundColor: AppColors.greyWhiteColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryIndigoColor.shade700,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryIndigoColor.shade700,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         title: Text(
//           widget.isEditMode ? 'Edit Product' : 'Add Product',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           color: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   Center(
//                     child: InkWell(
//                       onTap: () => _showImagePickerSheet(context),
//                       borderRadius: BorderRadius.circular(16),
//                       child: Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           color: AppColors.greyWhiteColor,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: AppColors.primaryIndigoColor.shade300,
//                           ),
//                         ),
//                         child: _buildImageWidget(provider),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: buildInputDecoration('Product Name'),
//                     onChanged: provider.setName,
//                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [

//                       Expanded(
//                         flex: 3,
//                         child: TextFormField(
//                           controller: _weightController,
//                           decoration: buildInputDecoration('Quantity'),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           onChanged: (value) {
//                             // Combine weight value with unit
//                             provider.setWeight('$value $_selectedUnit');
//                           },
//                           validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         flex: 2,
//                         child: DropdownButtonFormField<String>(
//                           initialValue: _selectedUnit,
//                           decoration: buildInputDecoration('Unit'),
//                           items: _units.map((unit) {
//                             return DropdownMenuItem(
//                               value: unit,
//                               child: Text(unit,style: TextStyle(color: Colors.grey.shade600),),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedUnit = value!;
//                             });
//                             // Update weight with new unit
//                             if (_weightController.text.isNotEmpty) {
//                               provider.setWeight('${_weightController.text} $_selectedUnit');
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Prices
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _originalPriceController,
//                           decoration: buildInputDecoration('Original Price'),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           onChanged: provider.setOriginalPrice,
//                           validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _currentPriceController,
//                           decoration: buildInputDecoration('Current Price'),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           onChanged: provider.setCurrentPrice,
//                           validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _categoryController,
//                     decoration: buildInputDecoration('Category'),
//                     onChanged: provider.setCategory,
//                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Bulk Pricing Ranges',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primaryIndigoColor.shade700,
//                     ),
//                   ),

//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: TextField(
//                           controller: _minCtrl,
//                           decoration: buildInputDecoration('Min'),
//                           keyboardType: TextInputType.number,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         flex: 2,
//                         child: TextField(
//                           controller: _maxCtrl,
//                           decoration: buildInputDecoration('Max (-1 = ∞)'),
//                           keyboardType: TextInputType.number,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         flex: 3,
//                         child: TextField(
//                           controller: _priceCtrl,
//                           decoration: buildInputDecoration('Price'),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _discountCtrl,
//                           decoration: buildInputDecoration('Discount / unit'),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryIndigoColor,
//                           foregroundColor: Colors.white,
//                         ),
//                         onPressed: () => _addBulkRange(context),
//                         child: const Text('Add Range'),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),
//                   // Existing ranges list
//                   if (provider.bulkPricing.isNotEmpty)
//                     Column(
//                       children: provider.bulkPricing
//                           .asMap()
//                           .entries
//                           .map(
//                             (e) => Card(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           child: ListTile(
//                             title: Text(e.value.rangeText),
//                             subtitle: Text(
//                               'Price: ${e.value.priceText} | Discount: ${e.value.discountText}',
//                             ),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.delete_outline, color: Colors.red),
//                               onPressed: () => provider.removeBulkRange(e.key),
//                             ),
//                           ),
//                         ),
//                       )
//                           .toList(),
//                     ),

//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryIndigoColor,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (!_formKey.currentState!.validate()) return;
//                         if (!provider.isValidForm) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Check prices and required fields.'),
//                             ),
//                           );
//                           return;
//                         }

//                         final productId = widget.isEditMode && widget.product != null
//                             ? widget.product.id
//                             : DateTime.now().millisecondsSinceEpoch.toString();

//                         final product = provider.toProduct(
//                           productId,
//                           imagePath: provider.imageFile?.path ??
//                               (widget.product?.imagePath ?? ''),
//                         );

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               widget.isEditMode
//                                   ? 'Product updated successfully'
//                                   : 'Product saved successfully',
//                             ),
//                             backgroundColor: Colors.green,
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         );

//                         Navigator.pop(context, product);
//                       },
//                       child: Text(widget.isEditMode ? 'Update Product' : 'Save Product'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }




//   Widget _buildImageWidget(SellerProductProvider provider) {
//     // Show newly picked image
//     if (provider.imageFile != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.file(
//           provider.imageFile as File,
//           fit: BoxFit.cover,
//         ),
//       );
//     }

//     // Show existing product image in edit mode
//     if (widget.isEditMode && widget.product?.imagePath != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.asset(
//           widget.product.imagePath,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _buildPlaceholder(),
//         ),
//       );
//     }

//     // Show placeholder
//     return _buildPlaceholder();
//   }

//   Widget _buildPlaceholder() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           Icons.camera_alt_outlined,
//           color: AppColors.primaryIndigoColor.shade500,
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'Add Photo',
//           style: TextStyle(fontSize: 12),
//         ),
//       ],
//     );
//   }
// }
