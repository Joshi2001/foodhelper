
import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
import 'package:e_commerce/Screens/home_screen.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Services/Providers/auth.provider.dart';
import 'package:e_commerce/Services/Providers/orderprovider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/Services/Providers/subcategory.dart';
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce/route_generator.dart';
import 'package:provider/provider.dart';
import 'Services/Providers/profile_provider.dart';
import 'app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryOrangeColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: "https://grocerrybackend.onrender.com");
    
    return MultiProvider(
      providers: [
        // AuthProvider for managing login state
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(create: (_) => Home(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => SubCategoriesProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ServiceAreaProvider()),
      ],
      child: MaterialApp(
        title: 'FoodHelper',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
        home: const HomeScreen(), // ✅ Always go to HomeScreen first
        theme: AppTheme.appTHeme,
      ),
    );
  }
}

class AppTheme {
  static ThemeData get appTHeme {
    return ThemeData(
      primarySwatch: AppColors.primaryOrangeColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryOrangeColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryOrangeColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }
}
// import 'package:e_commerce/Screens/Auth/login_screen.dart';
// import 'package:e_commerce/Screens/coupon/coupon_provider.dart';
// import 'package:e_commerce/Screens/home_screen.dart';
// import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
// import 'package:e_commerce/Services/Providers/orderprovider.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/Services/Providers/subcategory.dart';
// import 'package:e_commerce/Services/api/apiservice.dart';
// import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:e_commerce/route_generator.dart';
// import 'package:provider/provider.dart';
// import 'Services/Providers/profile_provider.dart';
// import 'app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<bool> isLoggedIn() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');
//   return token != null && token.isNotEmpty;
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: AppColors.primaryOrangeColor,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.dark,
//     ),
//   );
//   runApp(const MainApp());
// }
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final apiService =
//         ApiService(baseUrl: "https://grocerrybackend.onrender.com");
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => Home(apiService: apiService),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => SubCategoriesProvider(apiService: apiService),
//         ),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()),
//          ChangeNotifierProvider(create: (_) => WishlistProvider()),
//          ChangeNotifierProvider(create: (_) => CouponProvider()),
//         ChangeNotifierProvider(create: (_) => OrderProvider()),
//          ChangeNotifierProvider(create: (_) => ServiceAreaProvider()),
//       ],
//       child: FutureBuilder<bool>(
//         future: isLoggedIn(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const MaterialApp(
//               debugShowCheckedModeBanner: false,
//               home: Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               ),
//             );
//           }

//           final loggedIn = snapshot.data ?? false;

//           return MaterialApp(
//             title: 'FoodHelper',
//             debugShowCheckedModeBanner: false,
//             onGenerateRoute: AppRouter.generateRoute,
//             home: loggedIn
//                 ? const HomeScreen() 
//                 : const LoginScreen(), 
//             theme: AppTheme.appTHeme,
//           );
//         },
//       ),
//     );
//   }
// }



// class AppTheme {
//   static ThemeData get appTHeme {
//     return ThemeData(

//       primarySwatch: AppColors.primaryOrangeColor,
//       scaffoldBackgroundColor: Colors.white,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.primaryOrangeColor,
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: IconThemeData(color: Colors.white),
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryOrangeColor,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//           systemNavigationBarColor: Colors.white,
//           systemNavigationBarIconBrightness: Brightness.dark,
//         ),
//       ),
//     );
//   }
// }



// class MainNavigationPage extends StatefulWidget {
//   const MainNavigationPage({super.key});

//   @override
//   State<MainNavigationPage> createState() => _MainNavigationPageState();
// }

// class _MainNavigationPageState extends State<MainNavigationPage> {
//   int selectedIndex = 0;

//   final List<Widget> pages = [
//     Center(child: Text("Home Screen")),
//     Center(child: Text("Orders Screen")),
//     Center(child: Text("Notifications Screen")),
//     Center(child: Text("Profile Screen")),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold( 
//       backgroundColor: AppColors.scaffoldBackgroundColor,

//       body: pages[selectedIndex],

//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: AppColors.primaryOrangeColor, 
//         currentIndex: selectedIndex,
//         onTap: (index) {
//           setState(() => selectedIndex = index);
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.white,  
//         unselectedItemColor: Colors.white70, 
//         elevation: 10,

//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined, size: 26),
//             activeIcon: Icon(Icons.home, size: 28),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag_outlined, size: 26),
//             activeIcon: Icon(Icons.shopping_bag, size: 28),
//             label: "Orders",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications_outlined, size: 26),
//             activeIcon: Icon(Icons.notifications, size: 28),
//             label: "Notifications",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline, size: 26),
//             activeIcon: Icon(Icons.person, size: 28),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }


 