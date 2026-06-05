// import 'dart:convert';
// import 'dart:io';
// import 'package:e_commerce/Screens/saller_add_product_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:provider/provider.dart';
// import '../Models/discount_range.dart';
// import '../Models/product.dart';
// import '../Services/Providers/seller_provider.dart';
// import '../app_colors.dart';
// import 'package:csv/csv.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:typed_data';

// import 'seller_product_detail_screen.dart';

// class SellerProductListScreen extends StatefulWidget {
//   const SellerProductListScreen({super.key});
//   @override
//   State<SellerProductListScreen> createState() => _SellerProductListScreenState();
// }

// class _SellerProductListScreenState extends State<SellerProductListScreen> {
//   int _rowsPerPage = 10;
//   String _searchQuery = '';
//   String _priceFilter = 'All';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   List<dynamic> _getFilteredProducts(List<dynamic> products) {
//     List<dynamic> filtered = products;

//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((product) {
//         final name = product.name.toLowerCase();
//         final price = product.currentPrice.toString();
//         final weight = product.weight.toLowerCase();
//         final query = _searchQuery.toLowerCase();
//         return name.contains(query) || price.contains(query) || weight.contains(query);
//       }).toList();
//     }

//     // Apply price filter
//     if (_priceFilter != 'All') {
//       filtered = filtered.where((product) {
//         if (_priceFilter == 'Low Price') {
//           return product.currentPrice < 500;
//         } else if (_priceFilter == 'High Price') {
//           return product.currentPrice >= 500;
//         } else if (_priceFilter == 'Discounted') {
//           return product.originalPrice > product.currentPrice;
//         }
//         return true;
//       }).toList();
//     }

//     return filtered;
//   }
//   Set<String> _selectedProductIds = {};
//   bool _selectAll = false;// ADD THESE THREE METHODS:
//   void _handleSelectAll(bool? value, List<dynamic> products) {
//     setState(() {
//       _selectAll = value ?? false;
//       if (_selectAll) {
//         _selectedProductIds = products.map((p) => p.id.toString()).toSet();
//       } else {
//         _selectedProductIds.clear();
//       }
//     });
//   }

//   void _handleSelectRow(String productId, bool? value) {
//     setState(() {
//       if (value ?? false) {
//         _selectedProductIds.add(productId);
//       } else {
//         _selectedProductIds.remove(productId);
//         _selectAll = false;
//       }
//     });
//   }

//   void _deleteSelectedProducts(SellerAccountProvider provider) {
//     if (_selectedProductIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No products selected')),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: const [
//             Icon(Icons.warning_amber_rounded, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Delete Products'),
//           ],
//         ),
//         content: Text('Delete ${_selectedProductIds.length} products?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               for (var id in _selectedProductIds) {
//                 provider.deleteProduct(id);
//               }
//               setState(() {
//                 _selectedProductIds.clear();
//                 _selectAll = false;
//               });
//               Navigator.pop(ctx);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Products deleted'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }


//   Future<void> _exportToCSV(BuildContext context, List<dynamic> products) async {
//     try {
//       // Check if products list is empty
//       if (products.isEmpty) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No products to export"),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//         return;
//       }

//       // BUILD CSV ROWS
//       List<List<dynamic>> rows = [
//         [
//           'Product ID',
//           'Product Name',
//           'Weight',
//           'Current Price',
//           'Original Price',
//           'Category',
//           'Image Path',
//           'Bulk Tier Min',
//           'Bulk Tier Max',
//           'Bulk Tier Price',
//           'Bulk Tier Discount',
//         ],
//       ];

//       for (var product in products) {
//         if (product.bulkPricing.isEmpty) {
//           rows.add([
//             product.id,
//             product.name,
//             product.weight,
//             product.currentPrice,
//             product.originalPrice,
//             product.category,
//             product.imagePath,
//             '', '', '', '',
//           ]);
//         } else {
//           for (var tier in product.bulkPricing) {
//             rows.add([
//               product.id,
//               product.name,
//               product.weight,
//               product.currentPrice,
//               product.originalPrice,
//               product.category,
//               product.imagePath,
//               tier.min,
//               tier.max,
//               tier.price,
//               tier.discount,
//             ]);
//           }
//         }
//       }

//       // Convert to CSV string
//       String csvData = const ListToCsvConverter().convert(rows);

//       // DEBUG: Check if CSV data is generated
//       print("CSV Data Length: ${csvData.length}");
//       print("First 100 chars: ${csvData.substring(0, csvData.length > 100 ? 100 : csvData.length)}");

//       if (csvData.isEmpty) {
//         throw Exception("CSV data is empty");
//       }

//       final fileName = "products_${DateTime.now().millisecondsSinceEpoch}.csv";

//       // Direct path to Downloads folder
//       final downloadsPath = "/storage/emulated/0/Download";
//       final filePath = "$downloadsPath/$fileName";

//       // Create file and write data
//       final file = File(filePath);

//       // METHOD 1: Write as string (preferred for CSV)
//       await file.writeAsString(csvData, flush: true);

//       // OR METHOD 2: Write as bytes (alternative)
//       // await file.writeAsBytes(utf8.encode(csvData), flush: true);

//       // Verify file was written
//       final fileExists = await file.exists();
//       final fileSize = await file.length();

//       print("File exists: $fileExists");
//       print("File size: $fileSize bytes");

//       if (context.mounted) {
//         if (fileSize > 0) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("✓ Saved $fileName ($fileSize bytes)"),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 5),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("File created but empty. Check product data."),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       }
//     } catch (e, stackTrace) {
//       print("Export Error: $e");
//       print("Stack trace: $stackTrace");

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }


//   Future<void> _importFromCSV(BuildContext context) async {
//     try {
//       // Pick CSV file
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['csv', 'txt'],
//         withData: true,
//       );

//       if (result == null) return;

//       Uint8List? bytes = result.files.single.bytes;

//       if (bytes == null || bytes.isEmpty) {
//         throw Exception("Selected file is empty (0 bytes)");
//       }

//       final csvString = utf8.decode(bytes);

//       if (csvString.trim().isEmpty) {
//         throw Exception("CSV content is empty");
//       }

//       if (!csvString.contains(',')) {
//         throw Exception("Invalid CSV file (no comma found)");
//       }

//       List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

//       if (csvData.length <= 1) {
//         throw Exception("CSV contains no data rows");
//       }

//       // Get provider
//       final provider = context.read<SellerAccountProvider>();

//       Map<String, Map<String, dynamic>> productMap = {};

//       // PARSE CSV DATA
//       for (int i = 1; i < csvData.length; i++) {
//         final row = csvData[i];
//         if (row.length < 11) continue;

//         final id = row[0].toString();
//         final name = row[1].toString();
//         final weight = row[2].toString();
//         final currentPrice = double.tryParse(row[3].toString()) ?? 0;
//         final originalPrice = double.tryParse(row[4].toString()) ?? 0;
//         final category = row[5].toString();
//         final imagePath = row[6].toString();

//         productMap.putIfAbsent(id, () {
//           return {
//             "id": id,
//             "name": name,
//             "weight": weight,
//             "currentPrice": currentPrice,
//             "originalPrice": originalPrice,
//             "category": category,
//             "imagePath": imagePath,
//             "bulkPricing": <DiscountRange>[],
//           };
//         });

//         // TIER FIELDS
//         final tMin = row[7].toString();
//         final tMax = row[8].toString();
//         final tPrice = row[9].toString();
//         final tDiscount = row[10].toString();

//         if (tMin.isNotEmpty || tPrice.isNotEmpty || tDiscount.isNotEmpty) {
//           productMap[id]!["bulkPricing"].add(
//             DiscountRange(
//               min: int.tryParse(tMin) ?? 0,
//               max: int.tryParse(tMax) ?? -1,
//               price: double.tryParse(tPrice) ?? 0,
//               discount: double.tryParse(tDiscount) ?? 0,
//             ),
//           );
//         }
//       }

//       // Add products to provider
//       int added = 0;
//       productMap.forEach((_, data) {
//         provider.addProduct(
//           Product(
//             id: data["id"],
//             name: data["name"],
//             weight: data["weight"],
//             currentPrice: data["currentPrice"],
//             originalPrice: data["originalPrice"],
//             category: data["category"],
//             imagePath: data["imagePath"],
//             bulkPricing: data["bulkPricing"],
//           ),
//         );
//         added++;
//       });

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Successfully imported $added products"),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error importing CSV: $e"),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SellerAccountProvider>();
//     final allProducts = provider.sellerProducts;
//     final filteredProducts = _getFilteredProducts(allProducts);

//     return Scaffold(
//       backgroundColor: AppColors.greyWhiteColor,
//       appBar:  AppBar(
//       automaticallyImplyLeading: false,
//       backgroundColor: AppColors.primaryIndigoColor.shade700,
//       systemOverlayStyle: SystemUiOverlayStyle(
//         statusBarColor: AppColors.primaryIndigoColor.shade700,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       title: const Text(
//         'My Products',
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//       ),
//       centerTitle: true,
//       // ADD THIS:
//       actions: [
//         if (_selectedProductIds.isNotEmpty)
//           Container(
//             width: 100,
// padding: EdgeInsets.only(right: 10),
//             // height: 30,
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               icon: SizedBox(
//                   width: 20,
//                   child: const Icon(Icons.delete, color: Colors.white, size: 18)),
//               label: Text('${_selectedProductIds.length}',style: TextStyle(color: Colors.white),),
//               onPressed: () => _deleteSelectedProducts(provider),
//             ),
//           ),

//       ],
//     ),

//     body: Column(
//         children: [
//           // Filter and Action Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [

//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search by Name, Price, Weight',
//                           prefixIcon: const Icon(Icons.search),
//                           suffixIcon: _searchQuery.isNotEmpty
//                               ? IconButton(
//                             icon: const Icon(Icons.clear, size: 20),
//                             onPressed: () {
//                               setState(() {
//                                 _searchQuery = '';
//                                 _searchController.clear();
//                               });
//                             },
//                           )
//                               : null,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           filled: true,
//                           fillColor: AppColors.greyWhiteColor,
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _searchQuery = value;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 5),


//                     Expanded(
//                       flex: 2,
//                       child: DropdownButtonFormField<String>(
//                         initialValue: _priceFilter,
//                         decoration: InputDecoration(
//                           labelText: 'Price Filter',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal:10,
//                             vertical: 12,
//                           ),
//                           filled: true,
//                           fillColor: AppColors.greyWhiteColor,
//                         ),
//                         items: ['All', 'Low Price', 'High Price', 'Discounted']
//                             .map((type) => DropdownMenuItem(
//                           value: type,
//                           child: Text(type,style: TextStyle(fontSize: 14),),
//                         ))
//                             .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _priceFilter = value!;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 // Action Buttons Row
//                 Row(
//                   spacing: 5,
//                   children: [

//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryIndigoColor,
//                           padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 4),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.add, color: Colors.white),
//                         label: const Text(
//                           'Add Product',
//                           style: TextStyle(color: Colors.white,fontSize: 12),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const SellerAddProductScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     // const SizedBox(width: 5),

//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 5),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.upload_file, color: Colors.white),
//                         label: const Text(
//                           'Import CSV',
//                           style: TextStyle(color: Colors.white,fontSize: 12),
//                         ),
//                         onPressed:()=> _importFromCSV(context),
//                       ),
//                     ),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         icon: const Icon(Icons.download, color: Colors.white),
//                         label: const Text(
//                           'Export CSV',
//                           style: TextStyle(color: Colors.white,fontSize: 12),
//                         ),
//                         onPressed: () => _exportToCSV( context,  filteredProducts as List<Product>),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Table Section
//           Expanded(
//             child: filteredProducts.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.inventory_2_outlined,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _searchQuery.isNotEmpty || _priceFilter != 'All'
//                         ? 'No products found'
//                         : 'No products yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : Theme(
//               data: Theme.of(context).copyWith(
//                 checkboxTheme: CheckboxThemeData(

//                   fillColor: WidgetStateProperty.resolveWith<Color>((states) {
//                     if (states.contains(WidgetState.selected)) {
//                       return AppColors.primaryIndigoColor; // When checked
//                     }
//                     return Colors.white; // When unchecked
//                   }),
//                   checkColor: WidgetStateProperty.all(Colors.white), // Checkmark color
//                   side: BorderSide(color: AppColors.primaryIndigoColor, width: 2), // Border color
//                 ),
//                 cardTheme: CardThemeData(
//                   elevation: 8,


//                   shadowColor: Colors.black26,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   color: Colors.white,
//                   // margin: const EdgeInsets.all(16),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: PaginatedDataTable(

//                   headingRowColor: WidgetStateProperty.resolveWith<Color?>(
//                         (Set<WidgetState> states) {

//                       return AppColors.primaryIndigoColor.shade700;
//                     },
//                   ),

//                   showCheckboxColumn: true,
//                   columns:  [


//                     const DataColumn(label: Text('Sr.No', style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Image',style: TextStyle(color: Colors.white),)),
//                     DataColumn(label: Text('Product Name' ,style: TextStyle(color: Colors.white))),
//                     const DataColumn(label: Text('Category', style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Weight',style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Price',style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Original Price',style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Bulk Tiers',style: TextStyle(color: Colors.white))),
//                     DataColumn(label: Text('Actions',style: TextStyle(color: Colors.white))),
//                   ],


//                   source: _ProductDataSource(
//                     products: filteredProducts,
//                     context: context,
//                     selectedIds: _selectedProductIds,
//                     onSelectRow: _handleSelectRow,
//                     onEdit: (product) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => SellerAddProductScreen(
//                             isEditMode: true,
//                             product: product,
//                           ),
//                         ),
//                       );

//                     },
//                     onDelete: (productId) => _showDeleteDialog(context, provider, productId),

//                     onTap: (product) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => SellerProductDetailScreen(product: product),
//                         ),
//                       );
//                     },
//                   ),
//                   rowsPerPage: _rowsPerPage,
//                   availableRowsPerPage: const [5, 10, 15, 20, 25, 30],
//                   onRowsPerPageChanged: (value) {
//                     setState(() {
//                       _rowsPerPage = value ?? 10;
//                     });
//                   },
//                   // showCheckboxColumn: false,
//                   showFirstLastButtons: true,
//                   columnSpacing: 15,

//                   horizontalMargin: 10,
//                   dataRowMinHeight: 50,
//                   dataRowMaxHeight: 60,
//                   headingRowHeight: 56,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteDialog(BuildContext context, SellerAccountProvider provider, String productId) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: const [
//             Icon(Icons.warning_amber_rounded, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Delete Product'),
//           ],
//         ),
//         content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             onPressed: () {
//               provider.deleteProduct(productId);
//               Navigator.pop(ctx);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text('Product deleted successfully'),
//                   backgroundColor: Colors.red,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               );
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }



// // DataSource remains the same as before
// class _ProductDataSource extends DataTableSource {
//   final List<dynamic> products;
//   final BuildContext context;
//   final Function(dynamic) onEdit;
//   final Function(String) onDelete;
//   final Function(dynamic) onTap;
//   final Set<String> selectedIds; // ADD
//   final Function(String, bool?) onSelectRow;

//   _ProductDataSource({
//     required this.products,
//     required this.context,
//     required this.selectedIds, // ADD
//     required this.onSelectRow,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onTap,
//   });

//   @override
//   DataRow? getRow(int index) {
//     if (index >= products.length) return null;
//     final product = products[index];
//     final isSelected = selectedIds.contains(product.id.toString()); // ADD
//     return DataRow(
//       selected: isSelected, // ADD this
//       onSelectChanged: (selected) { // CHANGE from onTap
//         onSelectRow(product.id.toString(), selected);
//       },
//       // onSelectChanged: (_) => onTap(product),
//       cells: [

//         DataCell(
//           Text(
//             '${index + 1}',
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//         ),
//         DataCell(
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.asset(
//               product.imagePath,
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 width: 60,
//                 height: 60,
//                 color: AppColors.greyWhiteColor,
//                 child: Icon(
//                   Icons.image,
//                   color: AppColors.primaryIndigoColor,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         DataCell(
//           SizedBox(
//             width: 150,
//             child: Text(
//               product.name,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//     DataCell(
//     Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//     color: AppColors.primaryIndigoColor.shade50,
//     borderRadius: BorderRadius.circular(6),
//     ),
//     child: Text(
//     product.category ?? '-',
//     style: TextStyle(
//     fontSize: 12,
//     color: AppColors.primaryIndigoColor.shade700,
//     fontWeight: FontWeight.w500,
//     ),
//     ),
//     ),),
//         DataCell(
//           Text(
//             product.weight,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ),
//         DataCell(
//           Text(
//             '₹${product.currentPrice.toStringAsFixed(0)}',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryIndigoColor,
//             ),
//           ),
//         ),
//         DataCell(
//           Text(
//             product.originalPrice > product.currentPrice
//                 ? '₹${product.originalPrice.toStringAsFixed(0)}'
//                 : '-',
//             style: TextStyle(
//               fontSize: 13,
//               decoration: product.originalPrice > product.currentPrice
//                   ? TextDecoration.lineThrough
//                   : null,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ),
//         DataCell(
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.primaryIndigoColor.shade100,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               '${product.bulkPricing.length} Tiers',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: AppColors.primaryIndigoColor.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         DataCell(
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   Icons.edit_outlined,
//                   color: AppColors.primaryIndigoColor,
//                   size: 20,
//                 ),
//                 onPressed: () => onEdit(product),
//               ),
//               IconButton(
//                 icon: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                   size: 20,
//                 ),
//                 onPressed: () => onDelete(product.id),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => products.length;

//   @override
//   int get selectedRowCount => selectedIds.length; // CHANGE from 0

// }


