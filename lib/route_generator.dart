import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Screens/aap_tearms.dart';
import 'package:e_commerce/Screens/editprofile.dart';
import 'package:e_commerce/Screens/notification_screen.dart';
import 'package:e_commerce/Screens/privacy.dart';
import 'package:e_commerce/UI/Widgets/Organisms/payment_option_screen.dart';
import 'package:e_commerce/UI/Widgets/address/add_address.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce/Screens/Auth/login_screen.dart';
import 'package:e_commerce/Screens/Auth/otp_verification_screen.dart';
import 'package:e_commerce/Screens/app_about_screen.dart';
import 'package:e_commerce/Screens/cart_gift_screen.dart';
import 'package:e_commerce/Screens/error_screen.dart';
import 'package:e_commerce/Screens/home_screen.dart';
import 'package:e_commerce/Screens/order_confirmation_screen.dart';
import 'package:e_commerce/Screens/order_summary_screen.dart';
import 'package:e_commerce/Screens/pdf_view_screen.dart';
import 'package:e_commerce/Screens/products_screen.dart';
import 'package:e_commerce/Screens/profile_screen.dart';
import 'package:e_commerce/Screens/user_address_screen.dart';
import 'package:e_commerce/Screens/user_cart_screen.dart';
import 'package:e_commerce/Screens/user_orders_screen.dart';
import 'package:e_commerce/Screens/coupon/coupons_screeen.dart';

import 'Screens/product_detail_screen.dart';
import 'Screens/seller_home_screen.dart';
import 'Screens/store_setting_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return ScalePageRoute(
          builder: (_) => const LoginScreen(),
        );
      case '/otp/verify':
        return ScalePageRoute(
          builder: (_) => OTPVerificationScreen(
            data: settings.arguments,
          ),
          animationDirection: AnimationDirection.rightToLeft,
        );
      case '/home':
        return ScalePageRoute(

          builder: (_) => const HomeScreen(),
        );

      // case '/product/detail':
      //   return ScalePageRoute(
      //     builder: (_) => ProductDetailScreen(
      //       productId: settings.arguments as String, subCategories: ,
      //     ),
      //     animationDirection: AnimationDirection.rightToLeft,
      //   );

      // case '/products':
      //   return ScalePageRoute(
      //     builder: (_) => CategoryProductScreen(
      //       // categoryName: settings.arguments.toString(), productname: '', productid: settings.arguments.toString(),
      //     ),
      //     animationDirection: AnimationDirection.rightToLeft,
      //   );
      case '/coupons':
        return ScalePageRoute(
          builder: (_) => const CouponsSelectionScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case "/cart/gift":
        return ScalePageRoute(
          builder: (_) => const CartGiftScreen(),
        );
      case "/cart":
        return ScalePageRoute(
          builder: (_) => const CartScreen(),
        );
      case "/orders":
        return ScalePageRoute(
          builder: (_) => const OrdersScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );
      // case "/seller":
      //   return ScalePageRoute(
      //     builder: (_) => const SellerPanelHome(),
      //     animationDirection: AnimationDirection.rightToLeft,
      //   );
      // case "/order/summer":
      //   final order = settings.arguments as String?; 
      //   return ScalePageRoute(
      //     builder: (_) => OrderDetailsScreen( order: order,),
      //     animationDirection: AnimationDirection.rightToLeft,
      //   );

      case "/store-settings":
        final orderId = settings.arguments as String?; 
        return ScalePageRoute(
          builder: (_) =>StoreSettingScreen(), 
          animationDirection: AnimationDirection.rightToLeft,
        );
         case "/AddAddress":
        // final orderId = settings.arguments as String?; 
        return ScalePageRoute(
          builder: (_) =>AddAddress(), 
          animationDirection: AnimationDirection.rightToLeft,
        );
      case "/order/invoice":
        return ScalePageRoute(
          builder: (_) => const ViewOrderInvoiceScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );
      case "/order/confirm":
        return ScalePageRoute(
          builder: (_) => const OrderConfirmationScreen(),
        );
      case "/notifications":
  return ScalePageRoute(
    builder: (_) => const NotificationScreen(),
  );  case "/payment-option":
      return ScalePageRoute(
        builder: (_) => const PaymentOptionsScreen(),
      );
      case '/edit-profile':
        return ScalePageRoute(
          builder: (_) => const Editprofile(),
        );
      case '/profile':
        return ScalePageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case '/user/address':
        return ScalePageRoute(
          builder: (_) => const UserAddressScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );
      case '/app/about':
        return ScalePageRoute(
          builder: (_) => const AppAboutScreen(),
          animationDirection: AnimationDirection.rightToLeft,

        );
        case '/app/tearms':
        return ScalePageRoute(
          builder: (_) => const Tearms(),
          animationDirection: AnimationDirection.rightToLeft,
        );
         case '/app/privacy':
        return ScalePageRoute(
          builder: (_) => const Privacy(),
          animationDirection: AnimationDirection.rightToLeft,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreem(),
        );
    }
  }
}

enum AnimationDirection {
  leftToRight,
  rightToLeft,
  center,
}

class ScalePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final AnimationDirection animationDirection;

  ScalePageRoute({
    required this.builder,
    this.animationDirection = AnimationDirection.center,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return builder(context);
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            switch (animationDirection) {
              case AnimationDirection.leftToRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case AnimationDirection.rightToLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              case AnimationDirection.center:
              default:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: child,
                );
            }
          },
        );
}
