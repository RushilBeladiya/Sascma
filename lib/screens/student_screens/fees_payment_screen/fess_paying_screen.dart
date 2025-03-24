// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:sascma/controller/Student/home/student_home_controller.dart';
// import 'package:sascma/core/utils/colors.dart';

// class FeePaymentScreen extends StatefulWidget {
//   FeePaymentScreen({super.key});

//   @override
//   _FeePaymentScreenState createState() => _FeePaymentScreenState();
// }

// class _FeePaymentScreenState extends State<FeePaymentScreen> {
//   final StudentHomeController studentHomeController = Get.find();
//   Map<String, dynamic>? studentData;
//   Map<String, dynamic>? paymentData;
//   bool isLoading = true;

//   late Razorpay _razorpay;
//   bool _isPaid = false;

//   final DatabaseReference _studentRef =
//       FirebaseDatabase.instance.ref().child('student');
//   final DatabaseReference _paymentRef =
//       FirebaseDatabase.instance.ref().child('payments');
//   final DatabaseReference _transactionsRef =
//       FirebaseDatabase.instance.ref().child('transactions');

//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//     _fetchStudentData();
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

//   void _fetchStudentData() {
//     _studentRef
//         .child(studentHomeController.currentStudent.value.uid)
//         .once()
//         .then((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           studentData = Map<String, dynamic>.from(data);
//         });
//         _fetchPaymentData();
//       } else {
//         setState(() {
//           isLoading = false;
//           studentData = null;
//         });
//       }
//     }).catchError((_) {
//       setState(() {
//         isLoading = false;
//         studentData = null;
//       });
//     });
//   }

//   void _fetchPaymentData() {
//     if (studentData != null) {
//       final stream = studentData!['stream'];
//       final semester = studentData!['semester'];

//       _paymentRef
//           .child(stream)
//           .child('semesters')
//           .child(semester)
//           .once()
//           .then((event) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>?;

//         if (data != null) {
//           setState(() {
//             paymentData = Map<String, dynamic>.from(data);
//             _isPaid = paymentData!['status'] == 'Paid';
//           });
//         } else {
//           setState(() => paymentData = null);
//         }
//       }).whenComplete(() => setState(() => isLoading = false));
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     if (paymentData != null) {
//       final stream = studentData!['stream'];
//       final semester = studentData!['semester'];

//       await _paymentRef
//           .child(stream)
//           .child('semesters')
//           .child(semester)
//           .update({'status': 'Paid'});

//       final transactionData = {
//         "studentUID": studentHomeController.currentStudent.value.uid,
//         "amount": paymentData!['amount'],
//         "paymentId": response.paymentId,
//         "status": "Paid",
//         "timestamp": DateTime.now().toIso8601String(),
//       };

//       await _transactionsRef.child(response.paymentId!).set(transactionData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Payment Successful! ID: ${response.paymentId}'),
//         ),
//       );

//       setState(() => _isPaid = true);
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Payment failed: ${response.message}')),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('External Wallet: ${response.walletName}')),
//     );
//   }

//   void _openRazorpay() {
//     if (paymentData != null) {
//       var options = {
//         'key': 'rzp_test_xnFqX02uZhe2DM', // Replace with your Razorpay key
//         'amount': (int.parse(paymentData!['amount']) * 100).toString(),
//         'name': '${studentData!['firstName']} ${studentData!['lastName']}',
//         'description': 'Semester Fee Payment',
//         'prefill': {
//           'contact': studentData!['phoneNumber'],
//           'email': studentData!['email'],
//         },
//       };

//       try {
//         _razorpay.open(options);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black),
//               textAlign: TextAlign.end,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({required String title, required List<Widget> children}) {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style:
//                     const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             ...children
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fee Payment',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         backgroundColor: AppColor.primaryColor,
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Container(
//         color: AppColor.appBackGroundColor,
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : (studentData == null || paymentData == null)
//                 ? const Center(
//                     child: Text('No payment data available.',
//                         style: TextStyle(color: Colors.black54, fontSize: 18)),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       children: [
//                         _buildCard(
//                           title: 'Student Information',
//                           children: [
//                             _buildInfoRow('Name',
//                                 '${studentData!['firstName']} ${studentData!['lastName']}'),
//                             _buildInfoRow('SPID', studentData!['spid']),
//                             _buildInfoRow('Phone', studentData!['phoneNumber']),
//                             _buildInfoRow('Email', studentData!['email']),
//                           ],
//                         ),
//                         _buildCard(
//                           title: 'Fee Payment Details',
//                           children: [
//                             _buildInfoRow('Stream', studentData!['stream']),
//                             _buildInfoRow('Semester', studentData!['semester']),
//                             _buildInfoRow(
//                                 'Amount', '₹${paymentData!['amount']}'),
//                             _buildInfoRow(
//                               'Status',
//                               _isPaid ? 'Paid' : 'Unpaid',
//                               _isPaid ? Colors.green : Colors.red,
//                             ),
//                             const SizedBox(height: 20),
//                             ElevatedButton(
//                               onPressed: _isPaid ? null : _openRazorpay,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     _isPaid ? Colors.green : Colors.orange,
//                               ),
//                               child: Text(
//                                   _isPaid ? 'Payment Completed' : 'Pay Now'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//       ),
//     );
//   }
// }

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
//   late Razorpay _razorpay;
//   bool _isLoading = false;
//   bool _isPaid = false;
//   late DatabaseReference _paymentRef;
//   late DatabaseReference _feeRef;
//   String _amount = '10';

//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//     _paymentRef = FirebaseDatabase.instance.ref().child('payments');

//     /// ✅ Fetch dynamic fee amount and check payment status
//     _fetchFeeAmount();
//     _checkPaymentStatus();
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   /// ✅ Initialize Razorpay listeners
//   void _initializeRazorpay() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   /// ✅ Fetch fee amount dynamically from Firebase
//   Future<void> _fetchFeeAmount() async {
//     final student = studentHomeController.currentStudent.value;

//     if (student.stream.isEmpty || student.semester.isEmpty) {
//       print("Stream or Semester is missing.");
//       return;
//     }

//     try {
//       /// 🔥 Correct Firebase path with `semesters`
//       _feeRef = FirebaseDatabase.instance
//           .ref()
//           .child('payments/${student.stream}/semesters/${student.semester}');

//       final event = await _feeRef.once();
//       final snapshot = event.snapshot;

//       if (snapshot.value != null) {
//         final data =
//             Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

//         setState(() {
//           _amount = data['amount'] ?? '0';

//           /// ✅ Display dynamic amount
//         });
//       } else {
//         print("No fee data found for ${student.stream} - ${student.semester}");
//       }
//     } catch (e) {
//       print("Error fetching fee amount: $e");
//     }
//   }

//   /// ✅ Check payment status
//   Future<void> _checkPaymentStatus() async {
//     final student = studentHomeController.currentStudent.value;

//     try {
//       final event = await _paymentRef.once();
//       final snapshot = event.snapshot;

//       if (snapshot.value != null) {
//         final data =
//             Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

//         data.forEach((transactionId, payment) {
//           if (payment['spid'] == student.spid && payment['status'] == 'Paid') {
//             setState(() => _isPaid = true);
//           }
//         });
//       }
//     } catch (e) {
//       print("Error fetching payment status: $e");
//     }
//   }

//   /// ✅ Handle successful payment
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     setState(() => _isLoading = true);

//     final student = studentHomeController.currentStudent.value;

//     try {
//       final paymentData = {
//         'spid': student.spid,
//         'studentName': '${student.firstName} ${student.lastName}',
//         'amount': _amount,
//         'status': 'Paid',
//         'method': 'UPI',
//         'transactionId': response.paymentId,
//         'timestamp': DateTime.now().toIso8601String(),
//       };

//       /// ✅ Save payment record in Firebase
//       await _paymentRef.child(response.paymentId!).set(paymentData);

//       await Future.delayed(const Duration(seconds: 2));

//       await _checkPaymentStatus();

//       setState(() => _isLoading = false);

//       if (_isPaid) {
//         Get.snackbar(
//           'Success',
//           'Payment of ₹$_amount was successful!',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       print("Error during payment success handling: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   /// ✅ Handle payment error
//   void _handlePaymentError(PaymentFailureResponse response) {
//     setState(() => _isLoading = false);

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

//   /// ✅ Open Razorpay with dynamic fee amount
//   void _openRazorpay() {
//     final student = studentHomeController.currentStudent.value;

//     var options = {
//       'key': 'rzp_test_xnFqX02uZhe2DM', // Razorpay test key
//       'amount': int.parse(_amount) * 100, // Amount in paise
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
//       Get.snackbar('Error', 'Failed to open Razorpay: $e');
//     }
//   }

//   /// ✅ Student Info Card
//   Widget _buildStudentInfoCard() {
//     final student = studentHomeController.currentStudent.value;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           )
//         ],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: NetworkImage(student.profileImageUrl),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('${student.firstName} ${student.lastName}',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text('SPID: ${student.spid}',
//                     style: const TextStyle(color: Colors.black54)),
//                 Text('Phone: ${student.phoneNumber}',
//                     style: const TextStyle(color: Colors.black54)),
//                 Text('Email: ${student.email}',
//                     style: const TextStyle(color: Colors.black54)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ✅ Fee Payment Card
//   Widget _buildFeePaymentCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         title: Text(
//           'Amount: ₹$_amount',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           _isPaid ? 'Status: Paid' : 'Status: Unpaid',
//           style: TextStyle(
//             color: _isPaid ? Colors.green : Colors.red,
//             fontSize: 16,
//           ),
//         ),
//         trailing: ElevatedButton(
//           onPressed: _isPaid ? null : _openRazorpay,
//           child: Text(_isPaid ? 'Complete' : 'Pay Now'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _isPaid
//                 ? Colors.grey
//                 : AppColor.primaryColor, // ✅ Use AppColors
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Fee Payment'), centerTitle: true),
//       body: Obx(() {
//         return Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildStudentInfoCard(),
//                   const SizedBox(height: 20),
//                   _buildFeePaymentCard(),
//                 ],
//               ),
//             ),
//             if (_isLoading) const Center(child: CircularProgressIndicator()),
//           ],
//         );
//       }),
//     );
//   }
// }
//

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
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

//   @override
//   void initState() {
//     super.initState();
//     _fetchPaymentDetails();
//   }

//   /// ✅ Fetch dynamic payment details from Firebase with null safety
//   Future<void> _fetchPaymentDetails() async {
//     final student = studentHomeController.currentStudent.value;

//     if (student.stream.isEmpty || student.semester.isEmpty) {
//       print("Stream or Semester is missing.");
//       return;
//     }

//     try {
//       /// 🔥 Firebase path: `payments/${student.stream}/semesters/${student.semester}`
//       DatabaseReference ref = FirebaseDatabase.instance
//           .ref()
//           .child('payments/${student.stream}/semesters/${student.semester}');

//       print("Fetching data from Firebase path: ${ref.path}"); // Debug log

//       final event = await ref.once();
//       final snapshot = event.snapshot;

//       if (snapshot.value != null) {
//         final data = Map<String, dynamic>.from(snapshot.value as Map);

//         setState(() {
//           /// ✅ Use null safety and type handling
//           _amount =
//               (data['amount'] != null) ? data['amount'].toString() : 'N/A';
//           _timestamp = (data['timestamp'] != null)
//               ? data['timestamp'].toString()
//               : 'N/A';
//         });

//         print("Fetched amount: $_amount"); // ✅ Debug log
//         print("Fetched timestamp: $_timestamp"); // ✅ Debug log
//       } else {
//         print("No payment data found at path: ${ref.path}");

//         // Handle case where data does not exist
//         setState(() {
//           _amount = 'N/A';
//           _timestamp = 'N/A';
//         });

//         Get.snackbar(
//           'No Data Found',
//           'Payment data not found for ${student.stream} ${student.semester}.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Error fetching payment details: $e");

//       // Handle errors
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

//   @override
//   Widget build(BuildContext context) {
//     print('Hello'); // ✅ Print "Hello" in the console

//     final student = studentHomeController.currentStudent.value;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Payment Info'),
//         centerTitle: true,
//         backgroundColor: AppColor.primaryColor, // ✅ Use primary color
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
//                       'Semester: ${student.semester}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),

//                     Text(
//                       'Phone: ${student.phoneNumber}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),

//                     Text(
//                       'Email: ${student.email}',
//                       style:
//                           const TextStyle(fontSize: 16, color: Colors.black87),
//                     ),
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
//                       _timestamp == 'N/A' ? '' : 'Timestamp: $_timestamp',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black87,
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

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

      // Update paymentsComplete with payment data
      DatabaseReference paymentRef =
          FirebaseDatabase.instance.ref().child('paymentsComplete');
      await paymentRef.child(response.paymentId!).set(paymentData);

      // Update student's status to "paid" in the student collection
      DatabaseReference studentRef =
          FirebaseDatabase.instance.ref().child('student').child(student.uid);
      await studentRef.update({'status': 'paid'});

      // Also update the local student object in the controller
      studentHomeController.currentStudent.update((student) {
        student?.status = 'paid';
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isPaid = true;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final student = studentHomeController.currentStudent.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Payment Info'),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            /// ✅ Student Info Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(student.profileImageUrl),
                        backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// ✅ Student Info
                    Text(
                      'Name: ${student.firstName} ${student.lastName}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'SPID: ${student.spid}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(221, 0, 0, 0)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${student.email}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stream: ${student.stream}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Semester: ${student.semester}'
                      '-${student.division}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Payment Details Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _amount == 'N/A'
                          ? 'No payment data found for ${student.stream} ${student.semester}'
                          : 'Amount: ₹$_amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _amount == 'N/A' ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isPaid ? 'Status: Paid' : 'Status: Unpaid',
                      style: TextStyle(
                        color: _isPaid ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isPaid ? null : _openRazorpay,
                      child: Text(_isPaid ? 'Complete' : 'Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaid
                            ? Colors.grey
                            : AppColor.primaryColor, // ✅ Use AppColors
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
