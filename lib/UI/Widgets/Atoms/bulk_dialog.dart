// import 'dart:convert';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../Models/discount_range.dart';
// import '../../../Models/product.dart';
// import '../../../app_colors.dart';
// import 'package:http/http.dart' as http;

// class BulkDiscountDialog extends StatefulWidget {
//   final List<DiscountRange> ranges;
//   final Product product;

//   const BulkDiscountDialog({
//     super.key,  
//     required this.ranges,
//     required this.product,
//   });

//   @override
//   State<BulkDiscountDialog> createState() => _BulkDiscountDialogState();
// }
 
// class _BulkDiscountDialogState extends State<BulkDiscountDialog> {
//   late Future<List<DiscountRange>> _discountsFuture;
// Future<List<DiscountRange>> fetchDiscounts(String productId) async {
//   try {
//     final response = await http.get(
//       Uri.parse('https://grocerrybackend.onrender.com/api/public/pricing/$productId'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> body = jsonDecode(response.body);

//       final List<dynamic> data = body['data'] ?? [];             

//       return data
//           .where((d) =>
//               d is Map<String, dynamic> &&
//               d['minQty'] != null)
//           .map((d) => DiscountRange.fromJson(d))
//           .toList();
//     } else {
//       throw Exception(
//           "Failed to load discounts (Status: ${response.statusCode})");
//     }
//   } catch (e) {
//     debugPrint("fetchDiscounts error: $e");
//     rethrow;
//   }
// }

//   // Future<List<DiscountRange>> fetchDiscounts(String productId) async {
//   //   try {
//   //     final response = await http.get(
//   //       Uri.parse('https://grocerrybackend.onrender.com/api/discount/all'),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body) as List;
//   //       final productDiscounts = data
//   //           .where((d) => d['product'] != null && d['product']['_id'] == productId)
//   //           .map((d) => DiscountRange.fromJson(d))
//   //           .toList();
//   //       return productDiscounts;
//   //     } else {
//   //       print("Response: ${response.statusCode}");
//   //       throw Exception("Failed to load discounts: ${response.statusCode}");
//   //     }
//   //   } catch (e) {
//   //     print("Error:$e");
//   //     throw Exception("Error loading discounts: $e");
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     _discountsFuture = fetchDiscounts(widget.product.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<DiscountRange>>(
//       future: _discountsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Dialog(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text("Loading discounts..."),
//                 ],
//               ),
//             ),
//           );
//         }
        
//         if (snapshot.hasError) {
//           return Dialog(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.error, color: Colors.red, size: 48),
//                   const SizedBox(height: 16),
//                   Text("Error: ${snapshot.error}"),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text("Close"),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
        
//         final ranges = snapshot.data ?? [];
        
//         return Consumer<Home>(
//           builder: (context, homeProvider, child) {
//             final currentQuantity = homeProvider.getQuantity(widget.product.id);
//             final currentPrice = widget.product.getPriceForQuantity(currentQuantity);
//             final currentDiscount = widget.product.getDiscountForQuantity(currentQuantity);
          
//             return Dialog(
//               insetPadding: const EdgeInsets.all(0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.green.shade600,
//                                   Colors.green.shade400,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.green.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.discount,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Bulk Pricing Discounts",
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "${widget.product.name} - Save more!",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       if (currentQuantity > 0)
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade50,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.green.shade200,
//                               width: 2,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Current Cart Quantity",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black54,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "$currentQuantity units",
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green.shade700,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 8,
//                                           vertical: 4,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.green.shade100,
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           "₹$currentPrice each",
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.green.shade800,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               if (currentDiscount > 0)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade600,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       const Text(
//                                         "Saving",
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.white70,
//                                         ),
//                                       ),
//                                       Text(
//                                         "₹${(currentDiscount * currentQuantity).toStringAsFixed(0)}",
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.flash_on,
//                                   size: 18,
//                                   color: Colors.black,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   "Quick Add",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildQuickAddButton(
//                                     context,
//                                     homeProvider,
//                                     "+5",
//                                     5,
//                                     Icons.add_circle_outline,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: _buildQuickAddButton(
//                                     context,
//                                     homeProvider,
//                                     "+10",
//                                     10,
//                                     Icons.add_box_outlined,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: _buildQuickAddButton(
//                                     context,
//                                     homeProvider,
//                                     "-5",
//                                     5,
//                                     Icons.remove_circle_outline_outlined,
//                                     isMinus: true,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(12),
//                             topRight: Radius.circular(12),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 "Range",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Text(
//                                 "Price",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Text(
//                                 "Discount",
//                                 textAlign: TextAlign.right,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey.shade200, width: 2),
//                           borderRadius: const BorderRadius.only(
//                             bottomLeft: Radius.circular(12),
//                             bottomRight: Radius.circular(12),
//                           ),
//                         ),
//                         child: Column(
//                           children: ranges.isEmpty
//                               ? [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(vertical: 15.0),
//                                     child: Text(
//                                       "No discount ranges available",
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                   ),
//                                 ]
//                               : ranges.asMap().entries.map((entry) {
//                                   int index = entry.key;
//                                   DiscountRange range = entry.value;
//                                   bool isLast = index == ranges.length - 1;
//                                   final qty =
//                                       context.read<Home>().getQuantity(widget.product.id);
//                                   bool isActive = qty >= range.min &&
//                                       (range.max == -1 || qty <= range.max);

//                                   return Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 14,
//                                       horizontal: 12,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: isActive ? Colors.green.shade100 : Colors.white,
//                                       border: isLast
//                                           ? null
//                                           : Border(
//                                               bottom: BorderSide(
//                                                 color: Colors.grey.shade200,
//                                                 width: 1,
//                                               ),
//                                             ),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           flex: 2,
//                                           child: Row(
//                                             children: [
//                                               if (isActive)
//                                                 Icon(
//                                                   Icons.check_circle,
//                                                   size: 16,
//                                                   color: Colors.green.shade700,
//                                                 ),
//                                               if (isActive) const SizedBox(width: 6),
//                                               Expanded(
//                                                 child: Text(
//                                                   range.rangeText,
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: isActive
//                                                         ? FontWeight.bold
//                                                         : FontWeight.w600,
//                                                     color: isActive
//                                                         ? Colors.green.shade800
//                                                         : Colors.black87,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 1,
//                                           child: Text(
//                                             range.priceText,
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: isActive
//                                                   ? FontWeight.bold
//                                                   : FontWeight.w600,
//                                               color: isActive
//                                                   ? Colors.green.shade800
//                                                   : Colors.black87,
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 1,
//                                           child: Text(
//                                             range.discountText,
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: range.discountPercent <= 0
//                                                   ? Colors.grey
//                                                   : Colors.green.shade800,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: MediaQuery.sizeOf(context).width,
//                         child: TextButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           style: TextButton.styleFrom(
//                             backgroundColor: AppColors.primaryOrangeColor,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 2,
//                           ),
//                           child: const Text(
//                             "Done",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }
//     );
//   }

//   Widget _buildQuickAddButton(
//       BuildContext context,
//       Home homeProvider,
//       String label,
//       int quantity,
//       IconData icon,
//       {bool isMinus = false}
//       ) {
//     return ElevatedButton(
//       onPressed: () {
//         for (int i = 0; i < quantity; i++) {
//           if (isMinus) {
//             homeProvider.decrementQuantity(widget.product.id);
//           } else {
//             homeProvider.incrementQuantity(widget.product.id);
//           }
//         }
//         context.read<Home>().loadCart();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isMinus ? AppColors.primaryOrangeColor : Colors.green,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//           side: BorderSide(
//             color: isMinus ? AppColors.primaryOrangeColor.shade300 : Colors.green,
//             width: 1.5,
//           ),
//         ),
//         elevation: 0,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 24),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// // import 'dart:convert';

// // import 'package:e_commerce/Services/Providers/product_provider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../../Models/discount_range.dart';
// // import '../../../Models/product.dart';
// // import '../../../Services/Providers/cart_provider.dart';
// // import '../../../app_colors.dart';
// // import 'package:http/http.dart' as http;

// // class BulkDiscountDialog extends StatefulWidget {
// //   final List<DiscountRange> ranges;
// //   final Product product;

// //   const BulkDiscountDialog({
// //     super.key,  
// //     required this.ranges,
// //     required this.product,
// //   });

// //   @override
// //   State<BulkDiscountDialog> createState() => _BulkDiscountDialogState();
// // }
 
// // class _BulkDiscountDialogState extends State<BulkDiscountDialog> {
// //    Future<List<DiscountRange>> fetchDiscounts(String productId) async {
// //   final response = await http.get(
// //     Uri.parse('https://grocerrybackend.onrender.com/api/discount/all'),
// //   );

// //   if (response.statusCode == 200) {
// //     final data = jsonDecode(response.body) as List;
// //     final productDiscounts = data
// //         .where((d) => d['product']['_id'] == productId)
// //         .map((d) => DiscountRange.fromJson(d))
// //         .toList();
// //     return productDiscounts;
// //   } else {
// //     throw Exception("Failed to load discounts");
// //   }
// // }
// // @override
// //   void initState() {
// //     super.initState();
// //     _discountsFuture = fetchDiscounts(widget.product.id);
// //   }

// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<DiscountRange>>(
// //       future: _discountsFuture,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }
// //         if (snapshot.hasError) {
// //           return Center(child: Text("Error loading discounts"));
// //         }
// //         final ranges = snapshot.data ?? [];
// //     return Consumer<Home>(
// //       builder: (context, homeProvider, child) {
// //         final currentQuantity = homeProvider.getQuantity(widget.product.id);
// //         final currentPrice = widget.product.getPriceForQuantity(currentQuantity);
// //         final currentDiscount = widget.product.getDiscountForQuantity(currentQuantity);
      
// //         return Dialog(
// //           insetPadding: const EdgeInsets.all(0),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(20),
// //           ),
// //           child: SingleChildScrollView(
// //             child: Container(
// //               padding: const EdgeInsets.all(16),

// //               decoration: BoxDecoration(
// //                 // gradient: LinearGradient(
// //                 //   begin: Alignment.topLeft,
// //                 //   end: Alignment.bottomRight,
// //                 //   colors: [
// //                 //     AppColors.primaryOrangeColor.shade50,
// //                 //     Colors.white,
// //                 //   ],
// //                 // ),
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),

// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [

// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.all(10),
// //                         decoration: BoxDecoration(
// //                           gradient: LinearGradient(
// //                             colors: [
// //                               Colors.green.shade600,
// //                               Colors.green.shade400,

// //                               // AppColors.primaryOrangeColor.shade600,
// //                               // AppColors.primaryOrangeColor.shade400
// //                             ],
// //                           ),
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.green.withOpacity(0.3),
// //                               blurRadius: 8,
// //                               offset: const Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: const Icon(
// //                           Icons.discount,
// //                           color: Colors.white,
// //                           size: 28,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [

// //                             Text(
// //                               "Bulk Pricing Discounts",
// //                               style: TextStyle(
// //                                 fontSize: 20,
// //                                 fontWeight: FontWeight.bold,
// //                                 color:Colors.green,
// //                                 // AppColors.primaryOrangeColor.shade700,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               "${widget.product.name} - Save more!",
// //                               style: TextStyle(
// //                                 fontSize: 13,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),

// //                   // Current Quantity Display
// //                   if (currentQuantity > 0)
// //                     Container(
// //                       padding: const EdgeInsets.all(12),
// //                       margin: const EdgeInsets.only(bottom: 16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.green.shade50,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: Colors.green.shade200,
// //                           width: 2,
// //                         ),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               const Text(
// //                                 "Current Cart Quantity",
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.black54,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Row(
// //                                 children: [
// //                                   Text(
// //                                     "$currentQuantity units",
// //                                     style: TextStyle(
// //                                       fontSize: 20,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.green.shade700,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 8),
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 8,
// //                                       vertical: 4,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green.shade100,
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     child: Text(
// //                                       "₹$currentPrice each",
// //                                       style: TextStyle(
// //                                         fontSize: 11,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: Colors.green.shade800,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                           if (currentDiscount > 0)
// //                             Container(
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 12,
// //                                 vertical: 8,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.green.shade600,
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   const Text(
// //                                     "Saving",
// //                                     style: TextStyle(
// //                                       fontSize: 10,
// //                                       color: Colors.white70,
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     "₹${(currentDiscount * currentQuantity).toStringAsFixed(0)}",
// //                                     style: const TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),

// //                   // Quick Add Buttons
// //                   // Card(
// //                   //   elevation: 2,
// //                   //   color: Colors.white,
// //                   //   child:
// //                   Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       border: Border.all(color: Colors.grey.shade300),
// //                       borderRadius: BorderRadius.circular(12),
// //                       // border: Border.all(
// //                       //   color: Colors.grey.shade200,
// //                       //   width: 1.5,
// //                       // ),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Icon(
// //                               Icons.flash_on,
// //                               size: 18,
// //                               color: Colors.black,
// //                             ),
// //                             const SizedBox(width: 6),
// //                             Text(
// //                               "Quick Add",
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 10),
// //                         // Row(
// //                         //   children: [
// //                         //     Expanded(
// //                         //       child: _buildQuickAddButton(
// //                         //         context,
// //                         //         homeProvider,
// //                         //         "+5",
// //                         //         5,
// //                         //         Icons.add_circle_outline,
// //                         //       ),
// //                         //     ),
// //                         //     const SizedBox(width: 8),
// //                         //     Expanded(
// //                         //       child: _buildQuickAddButton(
// //                         //         context,
// //                         //         homeProvider,
// //                         //         "+10",
// //                         //         10,
// //                         //         Icons.add_box_outlined,
// //                         //       ),
// //                         //     ),
// //                         //     const SizedBox(width: 8),
// //                         //     Expanded(
// //                         //       child: _buildQuickAddButton(
// //                         //         context,
// //                         //         isMinus: true,
// //                         //         homeProvider,
// //                         //         "-5",
// //                         //         5,
// //                         //         Icons.remove_circle_outline_outlined,
// //                         //       ),
// //                         //     ),
// //                         //   ],
// //                         // ),
// //                         //
// //                         Row(
// //                           children: [
// //                             Expanded(
// //                               child: _buildQuickAddButton(
// //                                 context,
// //                                 homeProvider,
// //                                 "+5",
// //                                 5,
// //                                 Icons.add_circle_outline,
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),

// //                             Expanded(
// //                               child: _buildQuickAddButton(
// //                                 context,
// //                                 homeProvider,
// //                                 "+10",
// //                                 10,
// //                                 Icons.add_box_outlined,
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),

// //                             Expanded(
// //                               child: _buildQuickAddButton(
// //                                 context,
// //                                 homeProvider,
// //                                 "-5",
// //                                 5,
// //                                 Icons.remove_circle_outline_outlined,
// //                                 isMinus: true,
// //                               ),
// //                             ),
// //                           ],
// //                         )

// //                       ],
// //                     ),
// //                   ),
// //                   // ),

// //                   const SizedBox(height: 20),

// //                   // Table Header
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
// //                     decoration: BoxDecoration(

// //                       border: Border.all(color: Colors.grey.shade300),
// //                       // gradient: LinearGradient(
// //                       //   colors: [
// //                       //     AppColors.primaryOrangeColor.shade600,
// //                       //     AppColors.primaryOrangeColor.shade400
// //                       //   ],
// //                       // ),
// //                       //

// //                       borderRadius: const BorderRadius.only(
// //                         topLeft: Radius.circular(12),
// //                         topRight: Radius.circular(12),
// //                       ),
// //                       // boxShadow: [
// //                       //   BoxShadow(
// //                       //     color: AppColors.primaryOrangeColor.withOpacity(0.3),
// //                       //     blurRadius: 4,
// //                       //     offset: const Offset(0, 2),
// //                       //   ),
// //                       // ],
// //                     ),
// //                     //
// //                     child: const Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Expanded(
// //                           flex: 2,
// //                           child: Text(
// //                             "Range",
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           flex: 1,
// //                           child: Text(
// //                             "Price",
// //                             textAlign: TextAlign.center,
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                         ),
// //                         Expanded(
// //                           flex: 1,
// //                           child: Text(
// //                             "Discount",
// //                             textAlign: TextAlign.right,
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   // Table Data Rows
// //                  Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       border: Border.all(color: Colors.grey.shade200, width: 2),
// //                       borderRadius: const BorderRadius.only(
// //                         bottomLeft: Radius.circular(12),
// //                         bottomRight: Radius.circular(12),
// //                       ),
// //                     ),
// //                     child: Column(
// //                       children: ranges.asMap().entries.map((entry) {
// //                         int index = entry.key;
// //                         DiscountRange range = entry.value;
// //                         bool isLast = index == ranges.length - 1;
// //                         final currentQuantity =
// //                             context.read<Home>().getQuantity(widget.product.id);
// //                         bool isActive = currentQuantity >= range.min &&
// //                             (range.max == -1 || currentQuantity <= range.max);

// //                         return Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             vertical: 14,
// //                             horizontal: 12,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: isActive ? Colors.green.shade100 : Colors.white,
// //                             border: isLast
// //                                 ? null
// //                                 : Border(
// //                                     bottom: BorderSide(
// //                                       color: Colors.grey.shade200,
// //                                       width: 1,
// //                                     ),
// //                                   ),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Expanded(
// //                                 flex: 2,
// //                                 child: Row(
// //                                   children: [
// //                                     if (isActive)
// //                                       Icon(
// //                                         Icons.check_circle,
// //                                         size: 16,
// //                                         color: Colors.green.shade700,
// //                                       ),
// //                                     if (isActive) const SizedBox(width: 6),
// //                                     Expanded(
// //                                       child: Text(
// //                                         range.rangeText,
// //                                         style: TextStyle(
// //                                           fontSize: 14,
// //                                           fontWeight: isActive
// //                                               ? FontWeight.bold
// //                                               : FontWeight.w600,
// //                                           color: isActive
// //                                               ? Colors.green.shade800
// //                                               : Colors.black87,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 1,
// //                                 child: Text(
// //                                   range.priceText,
// //                                   //(widget.product.basePrice),
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     fontWeight: isActive
// //                                         ? FontWeight.bold
// //                                         : FontWeight.w600,
// //                                     color: isActive
// //                                         ? Colors.green.shade800
// //                                         : Colors.black87,
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 flex: 1,
// //                                 child: Text(
// //                                   range.discountText,
// //                                   textAlign: TextAlign.right,
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: range.discountPercent == 0
// //                                         ? Colors.grey
// //                                         : Colors.green.shade800,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),

// //                   // const SizedBox(height: 20),
// //                   //
// //                   // // Maximum Savings Section
// //                   // Container(
// //                   //   padding: const EdgeInsets.all(16),
// //                   //   decoration: BoxDecoration(
// //                   //     gradient: LinearGradient(
// //                   //       colors: [
// //                   //         AppColors.primaryOrangeColor.shade600,
// //                   //         AppColors.primaryOrangeColor.shade400,
// //                   //         AppColors.primaryOrangeColor.shade300,
// //                   //       ],
// //                   //       begin: Alignment.topLeft,
// //                   //       end: Alignment.bottomRight,
// //                   //     ),
// //                   //     borderRadius: BorderRadius.circular(12),
// //                   //     boxShadow: [
// //                   //       BoxShadow(
// //                   //         color: AppColors.primaryOrangeColor.withOpacity(0.4),
// //                   //         blurRadius: 10,
// //                   //         offset: const Offset(0, 4),
// //                   //       ),
// //                   //     ],
// //                   //   ),
// //                   //   child: Column(
// //                   //     crossAxisAlignment: CrossAxisAlignment.start,
// //                   //     children: [
// //                   //       const Row(
// //                   //         children: [
// //                   //           Icon(Icons.savings, color: Colors.white, size: 24),
// //                   //           SizedBox(width: 8),
// //                   //           Text(
// //                   //             "Maximum Savings",
// //                   //             style: TextStyle(
// //                   //               fontWeight: FontWeight.bold,
// //                   //               fontSize: 16,
// //                   //               color: Colors.white,
// //                   //             ),
// //                   //           ),
// //                   //         ],
// //                   //       ),
// //                   //       const SizedBox(height: 12),
// //                   //       Container(
// //                   //         padding: const EdgeInsets.all(12),
// //                   //         decoration: BoxDecoration(
// //                   //           color: Colors.white.withOpacity(0.2),
// //                   //           borderRadius: BorderRadius.circular(8),
// //                   //           border: Border.all(
// //                   //             color: Colors.white.withOpacity(0.3),
// //                   //             width: 1,
// //                   //           ),
// //                   //         ),
// //                   //         child: Column(
// //                   //           crossAxisAlignment: CrossAxisAlignment.start,
// //                   //           children: [
// //                   //             Text(
// //                   //               "Example: ${widget.ranges.last.min} units × ${widget.ranges.last.priceText}",
// //                   //               style: const TextStyle(
// //                   //                 fontSize: 14,
// //                   //                 color: Colors.white,
// //                   //                 fontWeight: FontWeight.w600,
// //                   //               ),
// //                   //             ),
// //                   //             const SizedBox(height: 6),
// //                   //             Row(
// //                   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   //               children: [
// //                   //                 const Text(
// //                   //                   "Total Discount:",
// //                   //                   style: TextStyle(
// //                   //                     fontSize: 13,
// //                   //                     color: Colors.white,
// //                   //                   ),
// //                   //                 ),
// //                   //                 Text(
// //                   //                   "₹${(widget.ranges.last.min * widget.ranges.last.discount).toInt()}",
// //                   //                   style: const TextStyle(
// //                   //                     fontSize: 18,
// //                   //                     color: Colors.white,
// //                   //                     fontWeight: FontWeight.bold,
// //                   //                   ),
// //                   //                 ),
// //                   //               ],
// //                   //             ),
// //                   //           ],
// //                   //         ),
// //                   //       ),
// //                   //       const SizedBox(height: 10),
// //                   //       Container(
// //                   //         padding: const EdgeInsets.symmetric(
// //                   //           horizontal: 8,
// //                   //           vertical: 4,
// //                   //         ),
// //                   //         decoration: BoxDecoration(
// //                   //           color: Colors.white.withOpacity(0.2),
// //                   //           borderRadius: BorderRadius.circular(6),
// //                   //         ),
// //                   //         child: Text(
// //                   //           "💰 Save up to ₹${widget.ranges.last.discount.toInt()} per unit on bulk orders!",
// //                   //           style: const TextStyle(
// //                   //             fontSize: 13,
// //                   //             color: Colors.white,
// //                   //             fontWeight: FontWeight.w600,
// //                   //           ),
// //                   //         ),
// //                   //       ),
// //                   //     ],
// //                   //   ),
// //                   // ),

// //                   const SizedBox(height: 16),

// //                   // Close Button
// //                   SizedBox(
// //                     width: MediaQuery.sizeOf(context).width,
// //                     // alignment: Alignment.centerRight,
// //                     child: TextButton(

// //                       onPressed: () => Navigator.of(context).pop(),
// //                       style: TextButton.styleFrom(
// //                         backgroundColor: AppColors.primaryOrangeColor,
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 24,
// //                           vertical: 12,
// //                         ),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         elevation: 2,
// //                       ),
// //                       child: const Text(
// //                         "Done",
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),

// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //       }
// //     );

// //   }


// //   Widget _buildQuickAddButton(
// //       BuildContext context,
// //       Home homeProvider,
// //       String label,
// //       int quantity,
// //       IconData icon,
// //       {bool isMinus=false, }
// //       ) {
// //     return ElevatedButton(
// //       onPressed: () {
// //         // Add quantity multiple times
// //         for (int i = 0; i < quantity;  i++) {
// //           isMinus==true?   homeProvider.decrementQuantity(widget.product.id):
// //           homeProvider.incrementQuantity(widget.product.id);

// //         }
// //         // context.read<CartProvider>().loadCartFromHome(homeProvider.getCartItemsLocal());
// //         context.read<Home>().loadCart();
// //       },
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor:  isMinus==true? AppColors.primaryOrangeColor:Colors.green ,
// //         foregroundColor: Colors.white,
// //         padding: const EdgeInsets.symmetric(vertical: 12),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(10),
// //           side: BorderSide(
// //             color: isMinus==true? AppColors.primaryOrangeColor.shade300:Colors.green,
// //             width: 1.5,
// //           ),
// //         ),
// //         elevation: 0,
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 24),
// //           const SizedBox(height: 4),
// //           Text(
// //             label,
// //             style: const TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

