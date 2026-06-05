// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../Services/Providers/seller_provider.dart';
// import '../app_colors.dart';
// class SellerDashboardScreen extends StatelessWidget {
//   const SellerDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SellerAccountProvider>();

//     return Scaffold(
//       backgroundColor: AppColors.greyWhiteColor,

//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(80),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: AppColors.primaryIndigoColor.shade700,
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarColor: AppColors.primaryIndigoColor.shade700,
//             statusBarIconBrightness: Brightness.light,
//           ),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primaryIndigoColor.shade600,
//                   AppColors.primaryIndigoColor.shade800,
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.white.withOpacity(0.3),
//                       child: Icon(
//                         Icons.store,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Welcome Back!',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'John\'s Store',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Quick Stats Grid (2x2)
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1.7,
//               children: [
//                 _buildModernStatCard(
//                   icon: Icons.inventory_2_outlined,
//                   title: 'Products',
//                   value: '${provider.totalProducts}',
//                   color: AppColors.primaryIndigoColor,
//                   gradient: [
//                     AppColors.primaryIndigoColor.shade400,
//                     AppColors.primaryIndigoColor.shade600,
//                   ],
//                 ),
//                 _buildModernStatCard(
//                   icon: Icons.shopping_cart_outlined,
//                   title: 'Orders',
//                   value: '24',
//                   color: Colors.orange,
//                   gradient: [
//                     Colors.orange.shade400,
//                     Colors.orange.shade600,
//                   ],
//                 ),

//                 _buildModernStatCard(
//                   icon: Icons.payments_outlined,
//                   title: 'Revenue',
//                   value: '₹42K',
//                   color: Colors.green,
//                   gradient: [
//                     Colors.green.shade400,
//                     Colors.green.shade600,
//                   ],
//                 ),

//                 _buildModernStatCard(
//                   icon: Icons.trending_up,
//                   title: 'Growth',
//                   value: '+12%',
//                   color: Colors.blue,
//                   gradient: [
//                     Colors.blue.shade400,
//                     Colors.blue.shade600,
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),

//             // Sales Chart Section
//             _buildSectionHeader('Sales Overview', Icons.bar_chart),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildChartLegend('This Week', Colors.green),
//                       _buildChartLegend('Last Week', Colors.grey.shade300),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       _buildChartBar('Mon', 0.6),
//                       _buildChartBar('Tue', 0.8),
//                       _buildChartBar('Wed', 0.5),
//                       _buildChartBar('Thu', 0.9),
//                       _buildChartBar('Fri', 0.7),
//                       _buildChartBar('Sat', 1.0),
//                       _buildChartBar('Sun', 0.4),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 24),

//             // Recent Activity
//             _buildSectionHeader('Recent Activity', Icons.access_time),
//             SizedBox(height: 12),
//             _buildEnhancedActivityCard(
//               'New Order Received',
//               'Order #ORD003 - ₹850',
//               '2 mins ago',
//               Icons.shopping_bag,
//               Colors.green,
//             ),
//             _buildEnhancedActivityCard(
//               'Product Updated',
//               'Atta, rice & Dals - Stock updated',
//               '1 hour ago',
//               Icons.edit_note,
//               Colors.blue,
//             ),
//             _buildEnhancedActivityCard(
//               'Order Delivered',
//               'Order #ORD001 delivered successfully',
//               '3 hours ago',
//               Icons.check_circle,
//               AppColors.primaryIndigoColor,
//             ),
//             SizedBox(height: 24),

//             // Quick Actions
//             _buildSectionHeader('Quick Actions', Icons.flash_on),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildActionButton(
//                     'Add Product',
//                     Icons.add_box_outlined,
//                     AppColors.primaryIndigoColor,
//                         () {},
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: _buildActionButton(
//                     'View Orders',
//                     Icons.list_alt,
//                     AppColors.primaryIndigoColor,
//                         () {},
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernStatCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//     required List<Color> gradient,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: gradient,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(icon, color: Colors.white, size: 24),
//                     ),

//                     SizedBox(height: 4),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),

//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.primaryIndigoColor, size: 22),
//         SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade800,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChartLegend(String label, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(3),
//           ),
//         ),
//         SizedBox(width: 6),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildChartBar(String label, double height) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 28,
//           height: 100 * height,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green.shade300, Colors.green.shade600],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildEnhancedActivityCard(
//       String title,
//       String subtitle,
//       String time,
//       IconData icon,
//       Color color,
//       ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             time,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       String label,
//       IconData icon,
//       Color color,
//       VoidCallback onTap,
//       ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 22),
//             SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 color: color,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
