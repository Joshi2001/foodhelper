import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'coupon_model.dart';

class CouponService {
  static const String baseUrl = 'https://grocerrybackend.onrender.com'; 

  Future<List<Coupon>> getCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/coupons'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> couponsData = responseData['data'];
          return couponsData.map((json) => Coupon.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load coupons: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load coupons. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching coupons: $e');
    }
  }
  
  Future<ApplyCouponResponse> applyCoupon(String couponCode, double orderTotal) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('User not logged in');
    }
    
    final request = {
      "couponCode": couponCode,
      "orderTotal": orderTotal,
    };
    
    print('Applying coupon: $request');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/coupons/apply'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(request),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Create response and then add coupon code
      final parsedResponse = ApplyCouponResponse.fromJson(responseData);
      
      // Return a new response with coupon code
      return ApplyCouponResponse(
        success: parsedResponse.success,
        discountAmount: parsedResponse.discountAmount,
        finalTotal: parsedResponse.finalTotal,
        message: parsedResponse.message,
        couponCode: couponCode, // Manually set coupon code
      );
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return ApplyCouponResponse(
        success: false,
        discountAmount: 0,
        finalTotal: orderTotal,
        message: errorData['message'] ?? 'Failed to apply coupon',
        couponCode: null,
      );
    }
  } catch (e) {
    print('Error applying coupon: $e');
    throw Exception('Error applying coupon: $e');
  }
}
}