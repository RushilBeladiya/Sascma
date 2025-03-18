import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  final StudentHomeController studentHomeController = Get.find();
  late Razorpay _razorpay;
  bool _isLoading = false;
  bool _isPaid = false; // Track payment status
  late DatabaseReference _paymentRef; // Firebase reference

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    /// ✅ Firebase reference
    _paymentRef = FirebaseDatabase.instance.ref().child('payment_gateway');

    /// ✅ Check for payment status on app start
    _checkPaymentStatus();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  /// ✅ Check payment status in Firebase
  Future<void> _checkPaymentStatus() async {
    final student = studentHomeController.currentStudent.value;

    _paymentRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);

        data.forEach((transactionId, payment) {
          if (payment['spid'] == student.spid && payment['status'] == 'Paid') {
            setState(() => _isPaid = true); // Mark as paid
          }
        });
      }
    });
  }

  /// ✅ Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);

    final student = studentHomeController.currentStudent.value;

    // Store payment details in Firebase
    final paymentData = {
      'spid': student.spid,
      'studentName': '${student.firstName} ${student.lastName}',
      'amount': '20125',
      'status': 'Paid',
      'method': 'UPI',
      'transactionId': response.paymentId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    /// ✅ Save payment data to Firebase
    await _paymentRef.child(response.paymentId!).set(paymentData);

    /// ✅ Simulate a 5-second loader delay
    await Future.delayed(Duration(seconds: 5));

    /// ✅ Check if payment was successful by verifying the SPID
    await _checkPaymentStatus();

    setState(() => _isLoading = false);

    /// ✅ Show success message
    if (_isPaid) {
      Get.snackbar(
        'Success',
        'Payment of ₹20,125 was successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Payment status verification failed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// ✅ Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      'Error: ${response.message}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ✅ Handle external wallet payment
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Wallet: ${response.walletName}');
  }

  /// ✅ Open Razorpay with student details
  void _openRazorpay() {
    final student = studentHomeController.currentStudent.value;

    var options = {
      'key': 'rzp_test_xnFqX02uZhe2DM', // Razorpay test key
      'amount': 2012500, // Amount in paise
      'name': 'SASCMA',
      'description': 'Fee Payment',
      'prefill': {
        'contact': student.phoneNumber,
        'email': student.email,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Failed to open Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Fee Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        final student = studentHomeController.currentStudent.value;

        if (student.uid.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// ✅ Student Profile Info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              NetworkImage(student.profileImageUrl),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${student.firstName} ${student.lastName}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('SPID: ${student.spid}',
                                  style: TextStyle(color: Colors.black54)),
                              Text('Phone: ${student.phoneNumber}',
                                  style: TextStyle(color: Colors.black54)),
                              Text('Email: ${student.email}',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  /// ✅ Fee Payment Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Amount: ₹20,125',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _isPaid ? 'Status: Paid' : 'Status: Unpaid',
                        style: TextStyle(
                          color: _isPaid ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: _isPaid ? null : _openRazorpay,
                        child: Text(_isPaid ? 'Complete' : 'Pay Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isPaid ? Colors.grey : Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ Loader during payment processing
            if (_isLoading) Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}
