import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  final StudentHomeController studentHomeController = Get.find();
  int expandedIndex = -1;
  String selectedPaymentMethod = 'Card'; // Default payment method

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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(student.profileImageUrl),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${student.firstName} ${student.lastName}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
              SizedBox(height: 16),
              // Fee Payment Section
              Expanded(
                child: ListView.builder(
                  itemCount: studentHomeController.feePayments.length,
                  itemBuilder: (context, index) {
                    final payment = studentHomeController.feePayments[index];
                    bool isExpanded = index == expandedIndex;
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount: ₹${payment.amount}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    expandedIndex = isExpanded ? -1 : index;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: payment.status == 'Paid'
                                      ? Colors.green
                                      : Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  payment.status == 'Paid' ? 'Paid' : 'Unpaid',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white, // Background color set to white
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Payment Method',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Radio(
                                      value: 'Card',
                                      groupValue: selectedPaymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPaymentMethod =
                                              value.toString();
                                        });
                                      },
                                    ),
                                    Text('Pay with Card',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 16),
                                    Radio(
                                      value: 'UPI',
                                      groupValue: selectedPaymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPaymentMethod =
                                              value.toString();
                                        });
                                      },
                                    ),
                                    Text('Pay with UPI',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
