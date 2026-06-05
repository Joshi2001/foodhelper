// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../app_colors.dart';
// import 'seller_dashboard_screen.dart';
// import 'seller_product_list_screen.dart';
// import 'seller_order_screen.dart';
// import 'seller_profile_page.dart';

// class SellerPanelHome extends StatefulWidget {
//   const SellerPanelHome({super.key});

//   @override
//   State<SellerPanelHome> createState() => _SellerPanelHomeState();
// }

// class _SellerPanelHomeState extends State<SellerPanelHome> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = const [
//     SellerDashboardScreen(),
//     SellerProductListScreen(),
//     SellerOrdersScreen(),
//     SellerProfileScreen(),
//   ];

//   void _onNavTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _updateSystemUI();
//   }

//   void _updateSystemUI() {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: AppColors.primaryIndigoColor.shade700,
//         statusBarIconBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _updateSystemUI();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: AppColors.primaryIndigoColor.shade700,
//         statusBarIconBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         body: _screens[_selectedIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: AppColors.primaryIndigoColor,
//           unselectedItemColor: Colors.grey,
//           currentIndex: _selectedIndex,
//           onTap: _onNavTap,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard_outlined),
//               activeIcon: Icon(Icons.dashboard),
//               label: 'Dashboard',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.inventory_2_outlined),
//               activeIcon: Icon(Icons.inventory_2),
//               label: 'Products',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_bag_outlined),
//               activeIcon: Icon(Icons.shopping_bag),
//               label: 'Orders',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
