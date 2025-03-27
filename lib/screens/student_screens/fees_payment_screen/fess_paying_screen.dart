import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';
import 'package:sascma/core/utils/colors.dart';

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  final StudentHomeController studentHomeController = Get.find();

  String _amount = '0';
  String _timestamp = '';
  bool _isPaid = false;
  bool _isLoading = false;
  late Razorpay _razorpay;
  String? _transactionId;
  Map<String, dynamic>? _paymentDetails;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
    _initializeRazorpay();
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

  Future<void> _fetchPaymentDetails() async {
    final student = studentHomeController.currentStudent.value;

    if (student.stream.isEmpty || student.semester.isEmpty) {
      print("Stream or Semester is missing.");
      return;
    }

    try {
      Query ref = FirebaseDatabase.instance
          .ref()
          .child('paymentsComplete')
          .orderByChild('uid')
          .equalTo(student.uid);

      print("Fetching payment status from Firebase path: ${ref.path}");

      final event = await ref.once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        data.forEach((key, value) {
          if (value['uid'] == student.uid && value['status'] == 'Paid') {
            setState(() {
              _isPaid = true;
            });
          }
        });
      }

      DatabaseReference feeRef = FirebaseDatabase.instance
          .ref()
          .child('payments/${student.stream}/semesters/${student.semester}');

      final feeEvent = await feeRef.once();
      final feeSnapshot = feeEvent.snapshot;

      if (feeSnapshot.value != null) {
        final feeData = Map<String, dynamic>.from(feeSnapshot.value as Map);

        setState(() {
          _amount = (feeData['amount'] != null)
              ? feeData['amount'].toString()
              : 'N/A';
          _timestamp = (feeData['timestamp'] != null)
              ? feeData['timestamp'].toString()
              : 'N/A';
        });

        print("Fetched amount: $_amount");
        print("Fetched timestamp: $_timestamp");
      } else {
        print("No fee data found at path: ${feeRef.path}");
      }
    } catch (e) {
      print("Error fetching payment details: $e");

      setState(() {
        _amount = 'N/A';
        _timestamp = 'N/A';
      });

      Get.snackbar(
        'Error',
        'Failed to fetch payment details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);

    final student = studentHomeController.currentStudent.value;

    try {
      final paymentData = {
        'spid': student.spid,
        'studentName': '${student.firstName} ${student.lastName}',
        'uid': student.uid,
        'amount': _amount,
        'stream': student.stream,
        'status': 'Paid',
        'method': 'UPI',
        'transactionId': response.paymentId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      DatabaseReference paymentRef =
          FirebaseDatabase.instance.ref().child('paymentsComplete');
      await paymentRef.child(response.paymentId!).set(paymentData);

      DatabaseReference studentRef =
          FirebaseDatabase.instance.ref().child('student').child(student.uid);
      await studentRef.update({'status': 'paid'});

      studentHomeController.currentStudent.update((student) {
        student?.status = 'paid';
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isPaid = true;
        _isLoading = false;
        _transactionId = response.paymentId;
        _paymentDetails = paymentData;
      });

      Get.snackbar(
        'Success',
        'Payment of ₹$_amount was successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print("Error during payment success handling: $e");
      setState(() => _isLoading = false);

      Get.snackbar(
        'Error',
        'Payment was successful but failed to update records: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);

    Get.snackbar(
      'Payment Failed',
      'Error: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Wallet: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openRazorpay() {
    final student = studentHomeController.currentStudent.value;

    var options = {
      'key': 'rzp_test_xnFqX02uZhe2DM',
      'amount': int.parse(_amount) * 100,
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
      print("Error opening Razorpay: $e");
      Get.snackbar(
        'Error',
        'Failed to open Razorpay: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadAndOpenReceipt() async {
    if (_transactionId == null || _paymentDetails == null) {
      Get.snackbar(
        'Error',
        'No payment details available to generate receipt',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfBytes = await _generatePdf();

      final file = await _savePdfToStorage(pdfBytes);

      await _openPdfFile(file);

      Get.snackbar(
        'Success',
        'Receipt downloaded and opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate receipt: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Uint8List> _generatePdf() async {
    final student = studentHomeController.currentStudent.value;
    final paymentDate = DateTime.parse(_paymentDetails!['timestamp']);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'SASCMA FEE RECEIPT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Receipt No: $_transactionId'),
            pw.Text('Date: ${_formatDate(paymentDate)}'),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('Student Name: ${student.firstName} ${student.lastName}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('SPID: ${student.spid}'),
            pw.Text('Stream: ${student.stream}'),
            pw.Text('Semester: ${student.semester}-${student.division}'),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Amount Paid:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('₹$_amount',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Payment Method: ${_paymentDetails!['method']}'),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'Thank You!',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<File> _savePdfToStorage(Uint8List pdfBytes) async {
    if (!await _requestStoragePermissions()) {
      throw Exception('Storage permission denied');
    }

    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = (await getExternalStorageDirectory())!;
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final student = studentHomeController.currentStudent.value;
    final file = File(
        '${directory.path}/SASCMA_Receipt_${student.spid}_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(pdfBytes);
    return file;
  }

  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      return await Permission.storage.isGranted;
    }
    return true;
  }

  Future<void> _openPdfFile(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _viewPaymentDetails() {
    if (_paymentDetails == null) return;

    Get.defaultDialog(
      title: 'Payment Details',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Transaction ID', _paymentDetails!['transactionId']),
            _buildDetailRow('Student Name', _paymentDetails!['studentName']),
            _buildDetailRow('SPID', _paymentDetails!['spid']),
            _buildDetailRow('Amount', '₹${_paymentDetails!['amount']}'),
            _buildDetailRow('Stream', _paymentDetails!['stream']),
            _buildDetailRow('Payment Method', _paymentDetails!['method']),
            _buildDetailRow('Status', _paymentDetails!['status']),
            _buildDetailRow(
                'Date',
                DateTime.parse(_paymentDetails!['timestamp'])
                    .toString()
                    .split(' ')[0]),
          ],
        ),
      ),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: Text('OK', style: TextStyle(color: AppColor.primaryColor)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = studentHomeController.currentStudent.value;

    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      appBar: AppBar(
        title: const Text('Fee Payment'),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(student.profileImageUrl),
                          backgroundColor:
                              AppColor.primaryColor.withOpacity(0.1),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${student.firstName} ${student.lastName}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SPID: ${student.spid}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                                Icons.school, 'Stream', student.stream),
                            _buildInfoItem(Icons.class_, 'Semester',
                                '${student.semester}-${student.division}'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(Icons.email, 'Email', student.email),
                            _buildInfoItem(
                                Icons.phone, 'Phone', student.phoneNumber),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildStatusItem(
                          'Amount',
                          '₹$_amount',
                          Icons.currency_rupee,
                          Colors.blue,
                        ),
                        _buildStatusItem(
                          'Status',
                          _isPaid ? 'Paid' : 'Pending',
                          _isPaid ? Icons.check_circle : Icons.pending,
                          _isPaid ? Colors.green : Colors.orange,
                        ),
                        if (_isPaid && _transactionId != null)
                          _buildStatusItem(
                            'Transaction ID',
                            _transactionId!,
                            Icons.receipt,
                            Colors.purple,
                          ),
                        SizedBox(height: 24),
                        if (!_isPaid)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openRazorpay,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'PAY NOW',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        if (_isPaid)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _downloadAndOpenReceipt,
                                  icon: Icon(Icons.download),
                                  label: Text('Download Receipt'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _viewPaymentDetails,
                                  icon: Icon(Icons.remove_red_eye),
                                  label: Text('View Details'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:sascma/controller/Student/home/student_home_controller.dart';
// import 'package:sascma/core/utils/colors.dart';

// class FeePaymentScreen extends StatefulWidget {
//   @override
//   _FeePaymentScreenState createState() => _FeePaymentScreenState();
// }

// class _FeePaymentScreenState extends State<FeePaymentScreen> {
//   final StudentHomeController studentHomeController = Get.find();

//   String _amount = '0';
//   String _timestamp = '';
//   bool _isPaid = false;
//   bool _isLoading = false;
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPaymentDetails();
//     _initializeRazorpay();
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   void _initializeRazorpay() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   Future<void> _fetchPaymentDetails() async {
//     final student = studentHomeController.currentStudent.value;

//     if (student.stream.isEmpty || student.semester.isEmpty) {
//       print("Stream or Semester is missing.");
//       return;
//     }

//     try {
//       Query ref = FirebaseDatabase.instance
//           .ref()
//           .child('paymentsComplete')
//           .orderByChild('uid')
//           .equalTo(student.uid);

//       print("Fetching payment status from Firebase path: ${ref.path}");

//       final event = await ref.once();
//       final snapshot = event.snapshot;

//       if (snapshot.value != null) {
//         final data = Map<String, dynamic>.from(snapshot.value as Map);

//         data.forEach((key, value) {
//           if (value['uid'] == student.uid && value['status'] == 'Paid') {
//             setState(() {
//               _isPaid = true;
//             });
//           }
//         });
//       }

//       DatabaseReference feeRef = FirebaseDatabase.instance
//           .ref()
//           .child('payments/${student.stream}/semesters/${student.semester}');

//       final feeEvent = await feeRef.once();
//       final feeSnapshot = feeEvent.snapshot;

//       if (feeSnapshot.value != null) {
//         final feeData = Map<String, dynamic>.from(feeSnapshot.value as Map);

//         setState(() {
//           _amount = (feeData['amount'] != null)
//               ? feeData['amount'].toString()
//               : 'N/A';
//           _timestamp = (feeData['timestamp'] != null)
//               ? feeData['timestamp'].toString()
//               : 'N/A';
//         });

//         print("Fetched amount: $_amount");
//         print("Fetched timestamp: $_timestamp");
//       } else {
//         print("No fee data found at path: ${feeRef.path}");
//       }
//     } catch (e) {
//       print("Error fetching payment details: $e");

//       setState(() {
//         _amount = 'N/A';
//         _timestamp = 'N/A';
//       });

//       Get.snackbar(
//         'Error',
//         'Failed to fetch payment details: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     setState(() => _isLoading = true);

//     final student = studentHomeController.currentStudent.value;

//     try {
//       final paymentData = {
//         'spid': student.spid,
//         'studentName': '${student.firstName} ${student.lastName}',
//         'uid': student.uid,
//         'amount': _amount,
//         'stream': student.stream,
//         'status': 'Paid',
//         'method': 'UPI',
//         'transactionId': response.paymentId,
//         'timestamp': DateTime.now().toIso8601String(),
//       };

//       // Update paymentsComplete with payment data
//       DatabaseReference paymentRef =
//           FirebaseDatabase.instance.ref().child('paymentsComplete');
//       await paymentRef.child(response.paymentId!).set(paymentData);

//       // Update student's status to "paid" in the student collection
//       DatabaseReference studentRef =
//           FirebaseDatabase.instance.ref().child('student').child(student.uid);
//       await studentRef.update({'status': 'paid'});

//       // Also update the local student object in the controller
//       studentHomeController.currentStudent.update((student) {
//         student?.status = 'paid';
//       });

//       await Future.delayed(const Duration(seconds: 2));

//       setState(() {
//         _isPaid = true;
//         _isLoading = false;
//       });

//       Get.snackbar(
//         'Success',
//         'Payment of ₹$_amount was successful!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       print("Error during payment success handling: $e");
//       setState(() => _isLoading = false);

//       Get.snackbar(
//         'Error',
//         'Payment was successful but failed to update records: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     setState(() => _isLoading = false);

//     Get.snackbar(
//       'Payment Failed',
//       'Error: ${response.message}',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Get.snackbar(
//       'External Wallet',
//       'Wallet: ${response.walletName}',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   void _openRazorpay() {
//     final student = studentHomeController.currentStudent.value;

//     var options = {
//       'key': 'rzp_test_xnFqX02uZhe2DM',
//       'amount': int.parse(_amount) * 100,
//       'name': 'SASCMA',
//       'description': 'Fee Payment',
//       'prefill': {
//         'contact': student.phoneNumber,
//         'email': student.email,
//       },
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print("Error opening Razorpay: $e");
//       Get.snackbar(
//         'Error',
//         'Failed to open Razorpay: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final student = studentHomeController.currentStudent.value;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Payment Info'),
//         centerTitle: true,
//         backgroundColor: AppColor.primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             /// ✅ Student Info Card
//             Card(
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// ✅ Profile Image
//                     Center(
//                       child: CircleAvatar(
//                         radius: 60,
//                         backgroundImage: NetworkImage(student.profileImageUrl),
//                         backgroundColor: AppColor.primaryColor.withOpacity(0.1),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     /// ✅ Student Info
//                     Text(
//                       'Name: ${student.firstName} ${student.lastName}',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     Text(
//                       'SPID: ${student.spid}',
//                       style: const TextStyle(
//                           fontSize: 16, color: Color.fromARGB(221, 0, 0, 0)),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Email: ${student.email}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Stream: ${student.stream}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),

//                     Text(
//                       'Semester: ${student.semester}'
//                       '-${student.division}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// ✅ Payment Details Card
//             Card(
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Payment Details',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _amount == 'N/A'
//                           ? 'No payment data found for ${student.stream} ${student.semester}'
//                           : 'Amount: ₹$_amount',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: _amount == 'N/A' ? Colors.red : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _isPaid ? 'Status: Paid' : 'Status: Unpaid',
//                       style: TextStyle(
//                         color: _isPaid ? Colors.green : Colors.red,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: _isPaid ? null : _openRazorpay,
//                       child: Text(_isPaid ? 'Complete' : 'Pay Now'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isPaid
//                             ? Colors.grey
//                             : AppColor.primaryColor, // ✅ Use AppColors
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }