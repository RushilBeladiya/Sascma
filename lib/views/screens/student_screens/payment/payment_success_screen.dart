import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/models/fee_payment_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final FeePayment payment;

  final String paymentId;
  final String amount;
  PaymentSuccessScreen(
      {required this.payment, required this.paymentId, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text('Payment Successful!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Payment ID: $paymentId'),
            SizedBox(height: 10),
            Text('Amount: ₹$amount'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
