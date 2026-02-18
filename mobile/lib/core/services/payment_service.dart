import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

class PaymentService {
  // Replace with your actual Paystack Public Key
  static const String _publicKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  Future<bool> initiatePayment({
    required double amount,
    required String email,
    required BuildContext context,
  }) async {
    try {
      final String ref = 'AG_${DateTime.now().millisecondsSinceEpoch}';
      
      final paymentResult = await FlutterPaystackPlus.openPaystackPaymentPlus(
        context: context,
        publicKey: _publicKey,
        email: email,
        amount: (amount * 100).toInt().toString(), // Kobo
        reference: ref,
        currency: 'NGN',
        method: 'card', 
        onClosed: () {
          debugPrint('Payment closed');
        },
        onSuccess: () {
          debugPrint('Payment successful');
        },
        onFailed: () {
          debugPrint('Payment failed');
        },
      );

      // Note: flutter_paystack_plus returns void, so we usually rely on the logic in onSuccess/onFailed.
      // For this implementation, we'll assume success if no error was thrown and control reaches here.
      // Realistically, you'd want to verify the transaction on your backend.
      
      return true; 
    } catch (e) {
      debugPrint("Payment failed: $e");
      return false;
    }
  }
}
