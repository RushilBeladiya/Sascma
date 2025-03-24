import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';
import 'package:sascma/core/utils/colors.dart';

class FeePaymentScreen extends StatefulWidget {
  FeePaymentScreen({super.key});

  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  final StudentHomeController studentHomeController = Get.find();
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? paymentData;
  bool isLoading = true;

  late Razorpay _razorpay;
  bool _isPaid = false;

  final DatabaseReference _studentRef =
      FirebaseDatabase.instance.ref().child('student');
  final DatabaseReference _paymentRef =
      FirebaseDatabase.instance.ref().child('payments');
  final DatabaseReference _transactionsRef =
      FirebaseDatabase.instance.ref().child('transactions');

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _fetchStudentData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _fetchStudentData() {
    _studentRef
        .child(studentHomeController.currentStudent.value.uid)
        .once()
        .then((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          studentData = Map<String, dynamic>.from(data);
        });
        _fetchPaymentData();
      } else {
        setState(() {
          isLoading = false;
          studentData = null;
        });
      }
    }).catchError((_) {
      setState(() {
        isLoading = false;
        studentData = null;
      });
    });
  }

  void _fetchPaymentData() {
    if (studentData != null) {
      final stream = studentData!['stream'];
      final semester = studentData!['semester'];

      _paymentRef
          .child(stream)
          .child('semesters')
          .child(semester)
          .once()
          .then((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            paymentData = Map<String, dynamic>.from(data);
            _isPaid = paymentData!['status'] == 'Paid';
          });
        } else {
          setState(() => paymentData = null);
        }
      }).whenComplete(() => setState(() => isLoading = false));
    } else {
      setState(() => isLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (paymentData != null) {
      final stream = studentData!['stream'];
      final semester = studentData!['semester'];

      await _paymentRef
          .child(stream)
          .child('semesters')
          .child(semester)
          .update({'status': 'Paid'});

      final transactionData = {
        "studentUID": studentHomeController.currentStudent.value.uid,
        "amount": paymentData!['amount'],
        "paymentId": response.paymentId,
        "status": "Paid",
        "timestamp": DateTime.now().toIso8601String(),
      };

      await _transactionsRef.child(response.paymentId!).set(transactionData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! ID: ${response.paymentId}'),
        ),
      );

      setState(() => _isPaid = true);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay() {
    if (paymentData != null) {
      var options = {
        'key': 'rzp_test_xnFqX02uZhe2DM', // Replace with your Razorpay key
        'amount': (int.parse(paymentData!['amount']) * 100).toString(),
        'name': '${studentData!['firstName']} ${studentData!['lastName']}',
        'description': 'Semester Fee Payment',
        'prefill': {
          'contact': studentData!['phoneNumber'],
          'email': studentData!['email'],
        },
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ...children
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Payment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        color: AppColor.appBackGroundColor,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (studentData == null || paymentData == null)
                ? const Center(
                    child: Text('No payment data available.',
                        style: TextStyle(color: Colors.black54, fontSize: 18)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildCard(
                          title: 'Student Information',
                          children: [
                            _buildInfoRow('Name',
                                '${studentData!['firstName']} ${studentData!['lastName']}'),
                            _buildInfoRow('SPID', studentData!['spid']),
                            _buildInfoRow('Phone', studentData!['phoneNumber']),
                            _buildInfoRow('Email', studentData!['email']),
                          ],
                        ),
                        _buildCard(
                          title: 'Fee Payment Details',
                          children: [
                            _buildInfoRow('Stream', studentData!['stream']),
                            _buildInfoRow('Semester', studentData!['semester']),
                            _buildInfoRow(
                                'Amount', '₹${paymentData!['amount']}'),
                            _buildInfoRow(
                              'Status',
                              _isPaid ? 'Paid' : 'Unpaid',
                              _isPaid ? Colors.green : Colors.red,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isPaid ? null : _openRazorpay,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isPaid ? Colors.green : Colors.orange,
                              ),
                              child: Text(
                                  _isPaid ? 'Payment Completed' : 'Pay Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
