import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/order.dart';
import '../../Models/product.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;
  List<Order> orders = [];
  String? errorMessage;
  Map<String, dynamic>? lastOrderSummary;

  Future<bool> createOrder({
    required String token,
    required Map<String, dynamic> address,
    required List<dynamic> cartItems,
    String? couponCode,
    double deliveryCharge = 0,
    double handlingCharge = 0,
    required double Function(dynamic, int) getFinalPrice,
  }) async {
    debugPrint("=================================");
    debugPrint("🛒 CREATE ORDER STARTED");
    debugPrint("=================================");
    
    debugPrint("📦 RECEIVED ADDRESS:");
    debugPrint("   fullName: ${address['fullName']}");
    debugPrint("   phone: ${address['phone']}");
    debugPrint("   address: ${address['address']}");
    debugPrint("   city: ${address['city']}");
    debugPrint("   pincode: ${address['pincode']}");
    debugPrint("   area: ${address['area']}");
    debugPrint("   house: ${address['house']}");
    debugPrint("   building: ${address['building']}");
    debugPrint("=================================");

    final url = Uri.parse('https://grocerrybackend.onrender.com/api/orders');

    double productSubtotal = 0;
    final List<Map<String, dynamic>> items = [];

    for (var item in cartItems) {
      final productId = item.product.id;
      
      // getFinalPrice should return UNIT price (price per piece)
      final unitPrice = getFinalPrice(item.product, item.quantity);
      final itemTotal = unitPrice ;
      productSubtotal += itemTotal;

      debugPrint("---------------------------------");
      debugPrint("📦 PRODUCT NAME => ${item.product.name}");
      debugPrint("💰 UNIT PRICE (from getFinalPrice) => ₹$unitPrice");
      debugPrint("🔢 QUANTITY => ${item.quantity}");
      debugPrint("💰 ITEM TOTAL (unitPrice × quantity) => $unitPrice × ${item.quantity} = ₹$itemTotal");
      debugPrint("💰 PRODUCT SUBTOTAL SO FAR => ₹$productSubtotal");

      items.add({
        "productId": productId,
        "type": item.product.source == "admin" ? "admin" : "vendor",
        "quantity": item.quantity,
        "price": itemTotal,  // Send TOTAL price for this item
      });
    }

    final double finalTotalWithCharges = productSubtotal + deliveryCharge + handlingCharge;

    debugPrint("=================================");
    debugPrint("💰 FINAL PRICE BREAKDOWN:");
    debugPrint("   Products Subtotal: ₹$productSubtotal");
    debugPrint("   Delivery Charge: ₹$deliveryCharge");
    debugPrint("   Handling Charge: ₹$handlingCharge");
    debugPrint("   FINAL TOTAL (with charges): ₹$finalTotalWithCharges");
    debugPrint("=================================");

    final bool hasCoupon = couponCode != null && couponCode.trim().isNotEmpty;

    String formattedAddress = _formatCompleteAddress(address);
    
    final addressData = {
      "fullName": address['fullName'] ?? address['name'] ?? address['receiverName'] ?? '',
      "phone": address['phone'] ?? address['receiverPhone'] ?? '',
      "addressLine": formattedAddress,
      "street": formattedAddress,
      "city": address['city'] ?? '',
      "state": address['state'] ?? address['city'] ?? '',
      "pincode": address['pincode'] ?? '',
      "area": address['area'] ?? address['areaName'] ?? '',
      "house": address['house'] ?? '',
      "building": address['building'] ?? '',
      "landmark": address['landmark'] ?? '',
      "floor": address['floor'] ?? '',
    };

    final body = <String, dynamic>{
      "items": items,
      "address": addressData,
      "city": address['city'] ?? '',
      "areaName": address['area'] ?? address['areaName'] ?? '',
      "pincode": address['pincode'] ?? '',
      "deliveryCharge": deliveryCharge,
      "handlingCharge": handlingCharge,
      "totalPrice": productSubtotal,
      "finalPrice": finalTotalWithCharges,
      "originalTotalPrice": productSubtotal,
      if (hasCoupon) "couponCode": couponCode.trim(),
    };

    debugPrint("=================================");
    debugPrint("📤 ORDER PAYLOAD");
    debugPrint(jsonEncode(body));
    debugPrint("=================================");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint("📥 RESPONSE STATUS => ${response.statusCode}");
      debugPrint("📦 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          lastOrderSummary = responseData['summary'] as Map<String, dynamic>?;
          debugPrint("✅ ORDER CREATED SUCCESSFULLY");
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      return false;
    }
  }

  String _formatCompleteAddress(Map<String, dynamic> address) {
    List<String> parts = [];
    
    if (address['house'] != null && address['house'].toString().isNotEmpty) {
      parts.add(address['house']);
    }
    if (address['floor'] != null && address['floor'].toString().isNotEmpty) {
      parts.add(address['floor']);
    }
    if (address['building'] != null && address['building'].toString().isNotEmpty) {
      parts.add(address['building']);
    }
    if (address['landmark'] != null && address['landmark'].toString().isNotEmpty) {
      parts.add(address['landmark']);
    }
    if (address['address'] != null && address['address'].toString().isNotEmpty) {
      parts.add(address['address']);
    }
    if (address['area'] != null && address['area'].toString().isNotEmpty) {
      parts.add(address['area']);
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city']);
    }
    if (address['pincode'] != null && address['pincode'].toString().isNotEmpty) {
      parts.add(address['pincode']);
    }
    
    return parts.join(', ');
  }

  Future<void> fetchMyOrders(String token) async {
    debugPrint("=================================");
    debugPrint("📦 FETCH MY ORDERS STARTED");
    debugPrint("=================================");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://grocerrybackend.onrender.com/api/orders/my');

      debugPrint("🌐 API URL => $url");
      debugPrint("🔑 TOKEN => $token");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("=================================");
      debugPrint("📥 RESPONSE RECEIVED");
      debugPrint("📊 STATUS CODE => ${response.statusCode}");
      debugPrint("=================================");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint("✅ RESPONSE JSON PARSED");

        List data = [];

        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          debugPrint("📂 RESPONSE TYPE => MAP");
          data = decoded['data'] as List? ?? [];
        } else if (decoded is List) {
          debugPrint("📂 RESPONSE TYPE => LIST");
          data = decoded;
        }

        debugPrint("📦 TOTAL ORDERS FOUND => ${data.length}");

        final List<Order> parsedOrders = [];

        for (var orderJson in data) {
          try {
            debugPrint("---------------------------------");
            debugPrint("📄 PARSING ORDER => ${orderJson['_id']}");
            
            debugPrint("💰 API finalPrice: ${orderJson['finalPrice']}");
            debugPrint("💰 API totalPrice: ${orderJson['totalPrice']}");
            debugPrint("💰 API deliveryCharge: ${orderJson['deliveryCharge'] ?? 0}");
            debugPrint("💰 API handlingCharge: ${orderJson['handlingCharge'] ?? 0}");
            
            parsedOrders.add(Order.fromJson(orderJson));
            debugPrint("✅ ORDER PARSED SUCCESSFULLY");
          } catch (e) {
            debugPrint("⚠️ SKIPPING ORDER");
            debugPrint("❌ ERROR => $e");
          }
        }

        orders = parsedOrders;

        debugPrint("=================================");
        debugPrint("✅ SUCCESSFULLY PARSED ${orders.length} ORDERS");
        
        for (var order in orders) {
          debugPrint("📦 ORDER ${order.id}: finalPrice = ₹${order.finalPrice}");
        }
        debugPrint("=================================");
      } else {
        errorMessage = 'Failed to fetch orders';
        debugPrint("❌ FAILED TO FETCH ORDERS");
        debugPrint("❌ STATUS CODE => ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      debugPrint("=================================");
      debugPrint("❌ ERROR IN fetchMyOrders");
      debugPrint("🔴 ERROR TYPE => ${e.runtimeType}");
      debugPrint("🔴 ERROR MESSAGE => $e");
      debugPrint("📍 STACKTRACE => $stackTrace");
      debugPrint("=================================");
    } finally {
      isLoading = false;
      debugPrint("🔄 LOADING FINISHED");
      debugPrint("📦 TOTAL ORDERS IN STATE => ${orders.length}");
      notifyListeners();
    }
  }

  void clearOrders() {
    debugPrint("🗑️ CLEARING ORDERS");
    orders.clear();
    errorMessage = null;
    notifyListeners();
    debugPrint("✅ ORDERS CLEARED");
  }

  Order? getOrderById(String orderId) {
    debugPrint("🔍 SEARCHING ORDER => $orderId");
    try {
      final order = orders.firstWhere((order) => order.id == orderId);
      debugPrint("✅ ORDER FOUND");
      return order;
    } catch (e) {
      debugPrint("❌ ORDER NOT FOUND");
      return null;
    }
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../Models/order.dart';
// import '../../Models/product.dart';

// class OrderProvider with ChangeNotifier {
//   bool isLoading = false;
//   List<Order> orders = [];
//   String? errorMessage;
//   Map<String, dynamic>? lastOrderSummary;

//   Future<bool> createOrder({
//     required String token,
//     required Map<String, dynamic> address,
//     required List<dynamic> cartItems,
//     String? couponCode,
//     double deliveryCharge = 0,
//     double handlingCharge = 0,
//     required double Function(dynamic, int) getFinalPrice,
//   }) async {
//     debugPrint("=================================");
//     debugPrint("🛒 CREATE ORDER STARTED");
//     debugPrint("=================================");
    
//     // Debug: Print received address
//     debugPrint("📦 RECEIVED ADDRESS:");
//     debugPrint("   fullName: ${address['fullName']}");
//     debugPrint("   phone: ${address['phone']}");
//     debugPrint("   address: ${address['address']}");
//     debugPrint("   city: ${address['city']}");
//     debugPrint("   pincode: ${address['pincode']}");
//     debugPrint("   area: ${address['area']}");
//     debugPrint("   house: ${address['house']}");
//     debugPrint("   building: ${address['building']}");
//     debugPrint("=================================");

//     final url = Uri.parse('https://grocerrybackend.onrender.com/api/orders');

//     double productSubtotal = 0;
//     final List<Map<String, dynamic>> items = [];

//     for (var item in cartItems) {
//       final productId = item.product.id;
//       final unitPrice = getFinalPrice(item.product, item.quantity);
//       final itemTotal = unitPrice * item.quantity;
//       productSubtotal += itemTotal;

//       debugPrint("---------------------------------");
//       debugPrint("📦 PRODUCT NAME => ${item.product.name}");
//       debugPrint("💰 UNIT PRICE => ₹$unitPrice");
//       debugPrint("🔢 QUANTITY => ${item.quantity}");
//       debugPrint("💰 ITEM TOTAL => ₹$itemTotal");

//       items.add({
//         "productId": productId,
//         "type": item.product.source == "admin" ? "admin" : "vendor",
//         "quantity": item.quantity,
//         "price": itemTotal,
//       });
//     }

//     final double finalTotalWithCharges = productSubtotal + deliveryCharge + handlingCharge;

//     debugPrint("=================================");
//     debugPrint("💰 PRICE BREAKDOWN:");
//     debugPrint("   Products Subtotal: ₹$productSubtotal");
//     debugPrint("   Delivery Charge: ₹$deliveryCharge");
//     debugPrint("   Handling Charge: ₹$handlingCharge");
//     debugPrint("   FINAL TOTAL (with charges): ₹$finalTotalWithCharges");
//     debugPrint("=================================");

//     final bool hasCoupon = couponCode != null && couponCode.trim().isNotEmpty;

//     String formattedAddress = _formatCompleteAddress(address);
    
//     final addressData = {
//       "fullName": address['fullName'] ?? address['name'] ?? address['receiverName'] ?? '',
//       "phone": address['phone'] ?? address['receiverPhone'] ?? '',
//       "addressLine": formattedAddress,
//       "street": formattedAddress,
//       "city": address['city'] ?? '',
//       "state": address['state'] ?? address['city'] ?? '',
//       "pincode": address['pincode'] ?? '',
//       "area": address['area'] ?? address['areaName'] ?? '',
//       "house": address['house'] ?? '',
//       "building": address['building'] ?? '',
//       "landmark": address['landmark'] ?? '',
//       "floor": address['floor'] ?? '',
//     };

//     final body = <String, dynamic>{
//       "items": items,
//       "address": addressData,
//       "city": address['city'] ?? '',
//       "areaName": address['area'] ?? address['areaName'] ?? '',
//       "pincode": address['pincode'] ?? '',
//       "deliveryCharge": deliveryCharge,
//       "handlingCharge": handlingCharge,
//       "totalPrice": productSubtotal,
//       "finalPrice": finalTotalWithCharges,
//       "originalTotalPrice": productSubtotal,
//       if (hasCoupon) "couponCode": couponCode.trim(),
//     };

//     debugPrint("=================================");
//     debugPrint("📤 ORDER PAYLOAD");
//     debugPrint(jsonEncode(body));
//     debugPrint("=================================");

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );

//       debugPrint("📥 RESPONSE STATUS => ${response.statusCode}");
//       debugPrint("📦 RESPONSE BODY => ${response.body}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
        
//         if (responseData['success'] == true) {
//           lastOrderSummary = responseData['summary'] as Map<String, dynamic>?;
//           debugPrint("✅ ORDER CREATED SUCCESSFULLY");
//           return true;
//         }
//       }
//       return false;
//     } catch (e) {
//       debugPrint("❌ ERROR: $e");
//       return false;
//     }
//   }

//   String _formatCompleteAddress(Map<String, dynamic> address) {
//     List<String> parts = [];
    
//     if (address['house'] != null && address['house'].toString().isNotEmpty) {
//       parts.add(address['house']);
//     }
//     if (address['floor'] != null && address['floor'].toString().isNotEmpty) {
//       parts.add(address['floor']);
//     }
//     if (address['building'] != null && address['building'].toString().isNotEmpty) {
//       parts.add(address['building']);
//     }
//     if (address['landmark'] != null && address['landmark'].toString().isNotEmpty) {
//       parts.add(address['landmark']);
//     }
//     if (address['address'] != null && address['address'].toString().isNotEmpty) {
//       parts.add(address['address']);
//     }
//     if (address['area'] != null && address['area'].toString().isNotEmpty) {
//       parts.add(address['area']);
//     }
//     if (address['city'] != null && address['city'].toString().isNotEmpty) {
//       parts.add(address['city']);
//     }
//     if (address['pincode'] != null && address['pincode'].toString().isNotEmpty) {
//       parts.add(address['pincode']);
//     }
    
//     return parts.join(', ');
//   }

//   Future<void> fetchMyOrders(String token) async {
//     debugPrint("=================================");
//     debugPrint("📦 FETCH MY ORDERS STARTED");
//     debugPrint("=================================");

//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     try {
//       final url = Uri.parse('https://grocerrybackend.onrender.com/api/orders/my');

//       debugPrint("🌐 API URL => $url");
//       debugPrint("🔑 TOKEN => $token");

//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       debugPrint("=================================");
//       debugPrint("📥 RESPONSE RECEIVED");
//       debugPrint("📊 STATUS CODE => ${response.statusCode}");
//       debugPrint("=================================");

//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         debugPrint("✅ RESPONSE JSON PARSED");

//         List data = [];

//         if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
//           debugPrint("📂 RESPONSE TYPE => MAP");
//           data = decoded['data'] as List? ?? [];
//         } else if (decoded is List) {
//           debugPrint("📂 RESPONSE TYPE => LIST");
//           data = decoded;
//         }

//         debugPrint("📦 TOTAL ORDERS FOUND => ${data.length}");

//         final List<Order> parsedOrders = [];

//         for (var orderJson in data) {
//           try {
//             debugPrint("---------------------------------");
//             debugPrint("📄 PARSING ORDER => ${orderJson['_id']}");
            
//             debugPrint("💰 API finalPrice: ${orderJson['finalPrice']}");
//             debugPrint("💰 API totalPrice: ${orderJson['totalPrice']}");
//             debugPrint("💰 API deliveryCharge: ${orderJson['deliveryCharge'] ?? 0}");
//             debugPrint("💰 API handlingCharge: ${orderJson['handlingCharge'] ?? 0}");
            
//             parsedOrders.add(Order.fromJson(orderJson));
//             debugPrint("✅ ORDER PARSED SUCCESSFULLY");
//           } catch (e) {
//             debugPrint("⚠️ SKIPPING ORDER");
//             debugPrint("❌ ERROR => $e");
//           }
//         }

//         orders = parsedOrders;

//         debugPrint("=================================");
//         debugPrint("✅ SUCCESSFULLY PARSED ${orders.length} ORDERS");
        
//         for (var order in orders) {
//           debugPrint("📦 ORDER ${order.id}: finalPrice = ₹${order.finalPrice}");
//         }
//         debugPrint("=================================");
//       } else {
//         errorMessage = 'Failed to fetch orders';
//         debugPrint("❌ FAILED TO FETCH ORDERS");
//         debugPrint("❌ STATUS CODE => ${response.statusCode}");
//       }
//     } catch (e, stackTrace) {
//       errorMessage = e.toString();
//       debugPrint("=================================");
//       debugPrint("❌ ERROR IN fetchMyOrders");
//       debugPrint("🔴 ERROR TYPE => ${e.runtimeType}");
//       debugPrint("🔴 ERROR MESSAGE => $e");
//       debugPrint("📍 STACKTRACE => $stackTrace");
//       debugPrint("=================================");
//     } finally {
//       isLoading = false;
//       debugPrint("🔄 LOADING FINISHED");
//       debugPrint("📦 TOTAL ORDERS IN STATE => ${orders.length}");
//       notifyListeners();
//     }
//   }

//   void clearOrders() {
//     debugPrint("🗑️ CLEARING ORDERS");
//     orders.clear();
//     errorMessage = null;
//     notifyListeners();
//     debugPrint("✅ ORDERS CLEARED");
//   }

//   Order? getOrderById(String orderId) {
//     debugPrint("🔍 SEARCHING ORDER => $orderId");
//     try {
//       final order = orders.firstWhere((order) => order.id == orderId);
//       debugPrint("✅ ORDER FOUND");
//       return order;
//     } catch (e) {
//       debugPrint("❌ ORDER NOT FOUND");
//       return null;
//     }
//   }
// }