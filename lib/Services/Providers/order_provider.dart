// import 'dart:convert';

// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Models/order.dart';
// import '../../Models/cart_item.dart';
// import '../../Models/product.dart';
// import '../../Models/discount_range.dart';
// import 'package:http/http.dart' as http;

// class OrderProvider with ChangeNotifier {
//     final List<Order> _orders = [];

//   List<Order> get orders => _orders;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   /// Fetch orders from API
//   Future<void> fetchMyOrders(String token, BuildContext context) async {
//   _isLoading = true;
//   notifyListeners();
   
   

//   try {
//     final apiService = context.read<Home>().apiService;
//     final response = await http.get(
//       Uri.parse('${apiService.baseUrl}/api/orders/my'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );

//     final decoded = jsonDecode(response.body);

//     if (response.statusCode == 200 && decoded['success'] == true) {
//       print(response.body);
//       final List data = decoded['data'];

//       _orders.clear();

//       for (final json in data) {
//         _orders.add(Order.fromApi(json));
//       }
//     }
//   } catch (e) {
//     debugPrint('Order API Error: $e');
//   }

//   _isLoading = false;
//   notifyListeners();
// }

//   // Future<void> fetchMyOrders(String token) async {
//   //   _isLoading = true;
//   //   notifyListeners();

//   //   try {
//   //     final response = await http.get(
//   //       Uri.parse('https://grocerrybackend.onrender.com/api/orders/my'),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization': 'Bearer $token',
//   //       },
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);
//   //       print(response.body);
//   //       _orders.clear();

//   //       for (final orderJson in data) {
//   //         _orders.add(Order.fromJson(orderJson));
//   //       }
//   //     } else {
//   //       debugPrint('Failed to load orders: ${response.body}');
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Order API Error: $e');
//   //   }

//   //   _isLoading = false;
//   //   notifyListeners();
//   // }

//   Order? getOrderById(String orderId) {
//     try {
//       return _orders.firstWhere((order) => order.id == orderId);
//     } catch (_) {
//       return null;
//     }
//   }

//   List<Order> getDeliveredOrders() {
//     return _orders.where((o) => o.status == 'delivered').toList();
//   }

//   List<Order> getPendingOrders() {
//     return _orders.where((o) => o.status == 'pending').toList();
//   }




//   // final List<Order> _orders = [];

//   // List<Order> get orders => _orders;

//   // OrderProvider() { 
//   //   _initializeSampleOrders();
//   // }

//   // void _initializeSampleOrders() {
//   // }

//   // Order? getOrderById(String orderId) {
//   //   try {
//   //     return _orders.firstWhere((order) => order.id == orderId);
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }

//   // void addOrder(Order order) {
//   //   _orders.insert(0, order);
//   //   notifyListeners();
//   // }

//   // List<Order> getDeliveredOrders() {
//   //   return _orders.where((order) => order.status == 'delivered').toList();
//   // }

//   // List<Order> getPendingOrders() {
//   //   return _orders.where((order) => order.status == 'pending').toList();
//   // }
// }
