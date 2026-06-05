// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class RazorpayService {
//   late Razorpay _razorpay;
//   Function(PaymentSuccessResponse)? onSuccess;
//   Function(PaymentFailureResponse)? onError;
//   Function(ExternalWalletResponse)? onExternalWallet;

//   RazorpayService({
//     this.onSuccess,
//     this.onError,
//     this.onExternalWallet,
//   }) {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   void openCheckout({
//     required int amount,
//     required String orderId,
//     required String name,
//     required String phone,
//     required String email,
//   }) {
//     var options = {
//       'key': 'rzp_test_RXG1QPP8Jk082R', 
//       'amount': amount * 100, 
//       'order_id': orderId,
//       'name': name,
//       'description': 'Order Payment',
//       'prefill': {
//         'contact': phone,
//         'email': email,
//       },
//       'theme': {
//         'color': '#3399cc',
//       },
//     };

//     _razorpay.open(options);
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     debugPrint('Payment Success: ${response.paymentId}');
//     onSuccess?.call(response);
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint('Payment Failed: ${response.message}');
//     onError?.call(response);
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint('External Wallet: ${response.walletName}');
//     onExternalWallet?.call(response);
//   }

//   void dispose() {
//     _razorpay.clear();
//   }
// }

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService({
    this.onSuccess,
    this.onError,
    this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required double amount,
    required String orderId,
    required String name,
    required String phone,
    required String email,
    String? description,
    Map<String, dynamic>? notes,
  }) {
    // Validate inputs
    if (amount <= 0) {
      debugPrint('Invalid amount: $amount');
      return;
    }

    var options = {
      'key': 'rzp_test_RXG1QPP8Jk082R',
      'amount': (amount * 100).toInt(),
      'order_id': orderId,
      'name': name,
      'description': description ?? 'Order Payment',
      'timeout': 300,
      'prefill': {
        'contact': phone,
        'email': email,
      },
      'theme': {
        'color': '#3399cc',
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      if (notes != null) 'notes': notes,
    };

    try {
      debugPrint('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      // Call error callback
      onError?.call(PaymentFailureResponse(
        0,
        'Failed to open Razorpay: $e',
        orderId as Map<dynamic, dynamic>?,
      ));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.code} - ${response.message}');
    // debugPrint('Order ID: ${response.orderId}');
    onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
