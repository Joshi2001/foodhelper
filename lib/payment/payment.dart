import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RazorpayOrderService {
  static const String keyId = 'rzp_test_RXG1QPP8Jk082R';
  static const String keySecret = 'ITONDbGrdwPZHU92Xmlm2n0P'; 
  
  static Future<String?> createOrder({
    required double amount,
    String currency = 'INR',
  }) async {
    try {
      final auth = base64Encode(utf8.encode('$keyId:$keySecret'));
      
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(), 
          'currency': currency,
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Order created: ${data['id']}');
        return data['id'];
      } else {
        debugPrint('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }
}