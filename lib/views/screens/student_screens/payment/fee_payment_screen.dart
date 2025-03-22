// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:sascma/controller/Student/home/student_home_controller.dart';

// class FeePaymentScreen extends StatefulWidget {
//   @override
//   _FeePaymentScreenState createState() => _FeePaymentScreenState();
// }

// class _FeePaymentScreenState extends State<FeePaymentScreen> {
//   final StudentHomeController studentHomeController = Get.find();
//   late Razorpay _razorpay;
//   bool _isLoading = false;
//   bool _isPaid = false; // Track payment status
//   late DatabaseReference _paymentRef; // Firebase reference
//   late DatabaseReference _feeRef; // Firebase reference for fee structure
//   String _feeAmount = 'NaN'; // Default fee amount

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//     /// ✅ Firebase references
//     _paymentRef = FirebaseDatabase.instance.ref().child('payment_gateway');
//     _feeRef = FirebaseDatabase.instance.ref().child('streams');

//     /// ✅ Check for payment status on app start
//     _checkPaymentStatus();

//     /// ✅ Fetch fee amount based on student's stream and semester
//     _fetchFeeAmount();
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   /// ✅ Fetch fee amount based on student's stream and semester
//   Future<void> _fetchFeeAmount() async {
//     final student = studentHomeController.currentStudent.value;

//     try {
//       DatabaseEvent event = await _feeRef
//           .child(student.stream)
//           .child('Semester ${student.semester}')
//           .once();

//       if (event.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(
//             event.snapshot.value as Map<dynamic, dynamic>);
//         setState(() {
//           _feeAmount = data['amount'].toString();
//         });
//       } else {
//         setState(() {
//           _feeAmount = 'NaN'; // If amount is not found
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _feeAmount = 'NaN'; // If an error occurs
//       });
//       Get.snackbar('Error', 'Failed to fetch fee amount: $e');
//     }
//   }

//   /// ✅ Check payment status in Firebase
//   Future<void> _checkPaymentStatus() async {
//     final student = studentHomeController.currentStudent.value;

//     _paymentRef.once().then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(
//             event.snapshot.value as Map<dynamic, dynamic>);

//         data.forEach((transactionId, payment) {
//           if (payment['spid'] == student.spid && payment['status'] == 'Paid') {
//             setState(() => _isPaid = true); // Mark as paid
//           }
//         });
//       }
//     });
//   }

//   /// ✅ Handle payment success
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     setState(() => _isLoading = true);

//     final student = studentHomeController.currentStudent.value;

//     // Store payment details in Firebase
//     final paymentData = {
//       'spid': student.spid,
//       'studentName': '${student.firstName} ${student.lastName}',
//       'amount': _feeAmount,
//       'status': 'Paid',
//       'method': 'UPI',
//       'transactionId': response.paymentId,
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     /// ✅ Save payment data to Firebase
//     await _paymentRef.child(response.paymentId!).set(paymentData);

//     /// ✅ Simulate a 5-second loader delay
//     await Future.delayed(Duration(seconds: 5));

//     /// ✅ Check if payment was successful by verifying the SPID
//     await _checkPaymentStatus();

//     setState(() => _isLoading = false);

//     /// ✅ Show success message
//     if (_isPaid) {
//       Get.snackbar(
//         'Success',
//         'Payment of ₹$_feeAmount was successful!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );
//     } else {
//       Get.snackbar(
//         'Error',
//         'Payment status verification failed!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );
//     }
//   }

//   /// ✅ Handle payment error
//   void _handlePaymentError(PaymentFailureResponse response) {
//     Get.snackbar(
//       'Payment Failed',
//       'Error: ${response.message}',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   /// ✅ Handle external wallet payment
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Get.snackbar('External Wallet', 'Wallet: ${response.walletName}');
//   }

//   /// ✅ Open Razorpay with student details
//   void _openRazorpay() {
//     final student = studentHomeController.currentStudent.value;

//     if (_feeAmount == 'NaN') {
//       Get.snackbar(
//         'Error',
//         'Fee amount is not available. Please contact admin.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     var options = {
//       'key': 'rzp_test_xnFqX02uZhe2DM', // Razorpay test key
//       'amount': int.parse(_feeAmount) * 100, // Amount in paise
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
//       Get.snackbar('Error', 'Failed to open Razorpay: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             Text('Fee Payment', style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         final student = studentHomeController.currentStudent.value;

//         if (student.uid.isEmpty) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   /// ✅ Student Profile Info
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.shade300,
//                           blurRadius: 8,
//                           offset: Offset(0, 4),
//                         )
//                       ],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 40,
//                           backgroundImage:
//                               NetworkImage(student.profileImageUrl),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('${student.firstName} ${student.lastName}',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold)),
//                               Text('SPID: ${student.spid}',
//                                   style: TextStyle(color: Colors.black54)),
//                               Text('Phone: ${student.phoneNumber}',
//                                   style: TextStyle(color: Colors.black54)),
//                               Text('Email: ${student.email}',
//                                   style: TextStyle(color: Colors.black54)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),

//                   /// ✅ Fee Payment Details Card
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.all(16),
//                       title: Text(
//                         'Amount: ₹$_feeAmount',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(
//                         _isPaid ? 'Status: Paid' : 'Status: Unpaid',
//                         style: TextStyle(
//                           color: _isPaid ? Colors.green : Colors.red,
//                           fontSize: 16,
//                         ),
//                       ),
//                       trailing: ElevatedButton(
//                         onPressed: _isPaid ? null : _openRazorpay,
//                         child: Text(_isPaid ? 'Complete' : 'Pay Now'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               _isPaid ? Colors.grey : Colors.orange,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// ✅ Loader during payment processing
//             if (_isLoading) Center(child: CircularProgressIndicator()),
//           ],
//         );
//       }),
//     );
//   }
// }
// -----------------------------------------------------------------------------------------------------------------------------------------------------

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:sascma/controller/Student/home/student_home_controller.dart';

// class FeePaymentScreen extends StatefulWidget {
//   @override
//   _FeePaymentScreenState createState() => _FeePaymentScreenState();
// }

// class _FeePaymentScreenState extends State<FeePaymentScreen> {
//   final StudentHomeController studentHomeController = Get.find();
//   late Razorpay _razorpay;
//   bool _isLoading = false;
//   bool _isPaid = false;
//   late DatabaseReference _paymentRef;
//   late DatabaseReference _feeRef;
//   String _feeAmount = 'NaN';
//   List<Map<String, dynamic>> paymentCollection = [];

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//     _paymentRef = FirebaseDatabase.instance.ref().child('payment_gateway');
//     _feeRef = FirebaseDatabase.instance.ref().child('payments');

//     _checkPaymentStatus();
//     _fetchFeeAmount();
//     _fetchPaymentCollection();
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   Future<void> _fetchFeeAmount() async {
//     final student = studentHomeController.currentStudent.value;

//     try {
//       DatabaseEvent event = await _feeRef
//           .child(student.stream)
//           .child('Semester ${student.semester}')
//           .once();

//       if (event.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(
//             event.snapshot.value as Map<dynamic, dynamic>);
//         setState(() {
//           _feeAmount = data['amount'].toString();
//         });
//       } else {
//         setState(() {
//           _feeAmount = 'NaN';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _feeAmount = 'NaN';
//       });
//       Get.snackbar('Error', 'Failed to fetch fee amount: $e');
//     }
//   }

//   Future<void> _checkPaymentStatus() async {
//     final student = studentHomeController.currentStudent.value;

//     _paymentRef.once().then((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(
//             event.snapshot.value as Map<dynamic, dynamic>);

//         data.forEach((transactionId, payment) {
//           if (payment['spid'] == student.spid && payment['status'] == 'Paid') {
//             setState(() => _isPaid = true);
//           }
//         });
//       }
//     });
//   }

//   Future<void> _fetchPaymentCollection() async {
//     _paymentRef.onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;

//       if (data != null) {
//         setState(() {
//           paymentCollection = data.entries.map((entry) {
//             final value = Map<String, dynamic>.from(entry.value);
//             return {
//               'transactionId': entry.key,
//               'spid': value['spid'],
//               'studentName': value['studentName'],
//               'amount': value['amount'],
//               'status': value['status'],
//               'method': value['method'],
//               'timestamp': value['timestamp'],
//             };
//           }).toList();
//         });
//       } else {
//         setState(() {
//           paymentCollection = [];
//         });
//       }
//     });
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     setState(() => _isLoading = true);

//     final student = studentHomeController.currentStudent.value;

//     final paymentData = {
//       'spid': student.spid,
//       'studentName': '${student.firstName} ${student.lastName}',
//       'amount': _feeAmount,
//       'status': 'Paid',
//       'method': 'UPI',
//       'transactionId': response.paymentId,
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     await _paymentRef.child(response.paymentId!).set(paymentData);

//     await Future.delayed(Duration(seconds: 5));

//     await _checkPaymentStatus();
//     await _fetchPaymentCollection();

//     setState(() => _isLoading = false);

//     if (_isPaid) {
//       Get.snackbar(
//         'Success',
//         'Payment of ₹$_feeAmount was successful!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );
//     } else {
//       Get.snackbar(
//         'Error',
//         'Payment status verification failed!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     Get.snackbar(
//       'Payment Failed',
//       'Error: ${response.message}',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Get.snackbar('External Wallet', 'Wallet: ${response.walletName}');
//   }

//   void _openRazorpay() {
//     final student = studentHomeController.currentStudent.value;

//     if (_feeAmount == 'NaN') {
//       Get.snackbar(
//         'Error',
//         'Fee amount is not available. Please contact admin.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     var options = {
//       'key': 'rzp_test_xnFqX02uZhe2DM', // Replace with your Razorpay key
//       'amount': int.parse(_feeAmount) * 100,
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
//       Get.snackbar('Error', 'Failed to open Razorpay: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             Text('Fee Payment', style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         final student = studentHomeController.currentStudent.value;

//         if (student.uid.isEmpty) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return ListView(
//           padding: const EdgeInsets.all(16.0),
//           children: [
//             /// ✅ Student Profile Info
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   )
//                 ],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('${student.firstName} ${student.lastName}',
//                       style:
//                           TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   Text('SPID: ${student.spid}'),
//                   Text('Phone: ${student.phoneNumber}'),
//                   Text('Email: ${student.email}'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),

//             /// ✅ Fee Payment Details
//             Card(
//               elevation: 4,
//               child: ListTile(
//                 title: Text('Amount: ₹$_feeAmount'),
//                 subtitle: Text(_isPaid ? 'Status: Paid' : 'Status: Unpaid'),
//                 trailing: ElevatedButton(
//                   onPressed: _isPaid ? null : _openRazorpay,
//                   child: Text(_isPaid ? 'Complete' : 'Pay Now'),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),

//             /// ✅ Set Amount Button
//             ElevatedButton(
//               onPressed: () {
//                 // Add functionality to set the amount
//               },
//               child: Text('Set Amount'),
//             ),
//             SizedBox(height: 20),

//             /// ✅ Payments Collection
//             Text('Payments Collection',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             ...paymentCollection
//                 .map((payment) => Card(
//                       elevation: 2,
//                       margin: EdgeInsets.symmetric(vertical: 4),
//                       child: ListTile(
//                         title: Text('SPID: ${payment['spid']}'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Amount: ₹${payment['amount']}'),
//                             Text('Status: ${payment['status']}'),
//                             Text('Method: ${payment['method']}'),
//                             Text('Date: ${payment['timestamp']}'),
//                           ],
//                         ),
//                       ),
//                     ))
//                 .toList(),
//           ],
//         );
//       }),
//     );
//   }
// }

// ---------------------------------------------------------------------
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class FeePaymentScreen extends StatefulWidget {
//   @override
//   _FeePaymentScreenState createState() => _FeePaymentScreenState();
// }

// class _FeePaymentScreenState extends State<FeePaymentScreen> {
//   late DatabaseReference _paymentRef;
//   List<Map<String, dynamic>> paymentCollection = [];

//   @override
//   void initState() {
//     super.initState();
//     _paymentRef = FirebaseDatabase.instance.ref().child('payments');
//     _fetchPaymentCollection();
//   }

//   /// ✅ Fetch payment collection from Firebase in real-time
//   Future<void> _fetchPaymentCollection() async {
//     _paymentRef.onValue.listen((event) {
//       final data = event.snapshot.value;

//       if (data != null && data is Map<dynamic, dynamic>) {
//         setState(() {
//           paymentCollection = data.entries.map((entry) {
//             final value = entry.value;
//             return {
//               'name': entry.key, // Payment name (e.g., BBA, BCA)
//               'semesters': value is Map<dynamic, dynamic>
//                   ? value
//                   : {}, // Ensure semesters is a Map
//             };
//           }).toList();
//         });
//       } else {
//         setState(() {
//           paymentCollection = [];
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Payments Collection',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: paymentCollection.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: paymentCollection.length,
//               itemBuilder: (context, index) {
//                 final payment = paymentCollection[index];
//                 final semesters = payment['semesters'] as Map<dynamic, dynamic>;

//                 return Card(
//                   elevation: 4,
//                   margin: EdgeInsets.symmetric(vertical: 8),
//                   child: ExpansionTile(
//                     title: Text('Payment: ${payment['name']}',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     children: semesters.entries.map((semester) {
//                       final semesterData = semester.value;
//                       return ListTile(
//                         title: Text('Semester: ${semester.key}'),
//                         subtitle: semesterData is Map<dynamic, dynamic>
//                             ? Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                       'Amount: ₹${semesterData['amount'] ?? 'N/A'}'),
//                                   Text(
//                                       'Date: ${semesterData['timestamp'] ?? 'N/A'}'),
//                                 ],
//                               )
//                             : Text('Invalid semester data'),
//                       );
//                     }).toList(),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  final StudentHomeController studentHomeController = Get.find();
  late DatabaseReference _paymentRef;
  List<Map<String, dynamic>> paymentCollection = [];
  List<Map<String, dynamic>> matchedPayments = [];
  bool showMatchedPayments = false;
  String matchMessage = ''; // Store match message

  @override
  void initState() {
    super.initState();
    _paymentRef = FirebaseDatabase.instance.ref().child('payments');
    _fetchPaymentCollection();
  }

  /// ✅ Fetch payment collection from Firebase in real-time
  Future<void> _fetchPaymentCollection() async {
    _paymentRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          paymentCollection = data.entries.map((entry) {
            final value = entry.value;
            return {
              'name': entry.key, // Stream name (e.g., BBA, BCA)
              'semesters': value is Map<dynamic, dynamic> ? value : {},
            };
          }).toList();
        });
      } else {
        setState(() {
          paymentCollection = [];
          matchedPayments = [];
        });
      }
    });
  }

  /// ✅ Filter and match payments with the student's stream and semester
  void _filterMatchedPayments() {
    final student = studentHomeController.currentStudent.value;

    /// 🔥 Filter payment records where the stream and semester both match
    matchedPayments = paymentCollection.where((payment) {
      final streamMatch = payment['name'] == student.stream;
      final semesters = payment['semesters'] as Map<dynamic, dynamic>;

      /// ✅ Check if the semester key exists in the current payment record
      final semesterKey = 'Semester ${student.semester}';
      final semesterMatch = semesters.containsKey(semesterKey);

      return streamMatch && semesterMatch;
    }).toList();

    /// ✅ Display the message based on matching result
    setState(() {
      showMatchedPayments = true;

      if (matchedPayments.isNotEmpty) {
        matchMessage =
            '✅ Current student Stream: ${student.stream} and Semester: ${student.semester} matches with the payment records.';
      } else {
        matchMessage =
            '❌ No match found for Stream: ${student.stream} and Semester: ${student.semester}.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = studentHomeController.currentStudent.value;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Fee Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${student.firstName} ${student.lastName}',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('SPID: ${student.spid}'),
                Text('Phone: ${student.phoneNumber}'),
                Text('Email: ${student.email}'),
                Text('Stream: ${student.stream}'),
                Text('Division: ${student.division}'),
                Text('Semester: ${student.semester}'),
              ],
            ),
          ),
          SizedBox(height: 20),

          /// ✅ All Payments Collection
          Text('All Payments Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          paymentCollection.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: paymentCollection.map((payment) {
                    final semesters =
                        payment['semesters'] as Map<dynamic, dynamic>;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Text('Payment: ${payment['name']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        children: semesters.entries.map((semester) {
                          final semesterData = semester.value;
                          return ListTile(
                            title: Text('Semester: ${semester.key}'),
                            subtitle: semesterData is Map<dynamic, dynamic>
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Amount: ₹${semesterData['amount'] ?? 'N/A'}'),
                                      Text(
                                          'Date: ${semesterData['timestamp'] ?? 'N/A'}'),
                                    ],
                                  )
                                : Text('Invalid semester data'),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
          SizedBox(height: 20),

          /// ✅ Match Payments Button
          ElevatedButton(
            onPressed: _filterMatchedPayments,
            child: Text('Match Payments'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          /// ✅ Display Match Message
          if (showMatchedPayments)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: matchedPayments.isNotEmpty
                    ? Colors.green[100]
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                matchMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: matchedPayments.isNotEmpty ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          /// ✅ Display Matched Payments
          if (showMatchedPayments)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Matched Payments',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                matchedPayments.isEmpty
                    ? Center(
                        child: Text('No matched payments found!',
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                      )
                    : Column(
                        children: matchedPayments.map((payment) {
                          final semesters =
                              payment['semesters'] as Map<dynamic, dynamic>;
                          final semesterData =
                              semesters['Semester ${student.semester}'];

                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text('Payment: ${payment['name']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: semesterData is Map<dynamic, dynamic>
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Amount: ₹${semesterData['amount'] ?? 'N/A'}'),
                                        Text(
                                            'Date: ${semesterData['timestamp'] ?? 'N/A'}'),
                                      ],
                                    )
                                  : Text('Invalid semester data'),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
        ],
      ),
    );
  }
}
