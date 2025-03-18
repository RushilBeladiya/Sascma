import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/faculty_model.dart';
import '../../../models/fee_payment_model.dart';
import '../../../models/student_model.dart';

class FacultyHomeController extends GetxController {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('faculty');
  final DatabaseReference feePaymentRef =
      FirebaseDatabase.instance.ref().child('fee_payments');
  final DatabaseReference studentRef =
      FirebaseDatabase.instance.ref().child('student');

  var facultyModel = FacultyModel(
    uid: '',
    firstName: '',
    lastName: '',
    surName: '',
    phoneNumber: '',
    email: '',
    profileImageUrl: '',
  ).obs;

  var feePayments = <FeePayment>[].obs;
  var stream = ['BCA', 'BBA', 'B.COM'].obs;
  var students = <StudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFacultyData();
    fetchFeePayments();
  }

  Future<void> fetchFacultyData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print("Fetching data for UID: ${user.uid}");

        DatabaseEvent event = await dbRef.child(user.uid).once();
        print("Raw Data: ${event.snapshot.value}");
        if (event.snapshot.value != null) {
          var data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            facultyModel.value = FacultyModel.fromMap(data);
            print(
                "User Loaded: ${facultyModel.value.firstName} ${facultyModel.value.lastName}");
          } else {
            print("Failed to parse user data.");
          }
        } else {
          print("No data found for UID: ${user.uid}");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load user data",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchFeePayments() async {
    try {
      DatabaseEvent event = await feePaymentRef.once();
      if (event.snapshot.value != null) {
        var data = event.snapshot.value as Map<dynamic, dynamic>;
        feePayments
            .assignAll(data.values.map((e) => FeePayment.fromMap(e)).toList());
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load fee payments");
    }
  }

  void fetchFeePaymentsByStream(String stream) async {
    try {
      DatabaseEvent event =
          await feePaymentRef.orderByChild('stream').equalTo(stream).once();
      if (event.snapshot.value != null) {
        var data = event.snapshot.value as Map<dynamic, dynamic>;
        var payments = data.values.map((e) => FeePayment.fromMap(e)).toList();

        for (var payment in payments) {
          DatabaseEvent studentEvent =
              await studentRef.child(payment.studentId).once();
          if (studentEvent.snapshot.value != null) {
            var studentData =
                studentEvent.snapshot.value as Map<dynamic, dynamic>;
            payment.studentName =
                '${studentData['firstName']} ${studentData['lastName']}';
          }
        }

        feePayments.assignAll(payments);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load fee payments");
    }
  }

  void fetchStudentsByStream(String stream) async {
    try {
      DatabaseEvent studentEvent = await FirebaseDatabase.instance
          .ref()
          .child('student')
          .orderByChild('stream')
          .equalTo(stream)
          .once();

      if (studentEvent.snapshot.value != null) {
        var studentData = studentEvent.snapshot.value as Map<dynamic, dynamic>?;

        if (studentData != null) {
          List<StudentModel> fetchedStudents = [];
          for (var entry in studentData.entries) {
            StudentModel student = StudentModel.fromMap(entry.value);
            student.uid = entry.key; // Assign UID

            // ✅ Check payment status from payment_gateway
            DatabaseEvent paymentEvent = await FirebaseDatabase.instance
                .ref()
                .child('payment_gateway')
                .orderByChild('spid')
                .equalTo(student.spid)
                .once();

            if (paymentEvent.snapshot.value != null) {
              var paymentData =
                  paymentEvent.snapshot.value as Map<dynamic, dynamic>;

              var paymentStatus =
                  paymentData.values.first['status'] ?? 'Unpaid';
              student.status = paymentStatus == 'Paid' ? 'Paid' : 'Unpaid';
            } else {
              student.status = 'Unpaid';
            }

            fetchedStudents.add(student);
          }

          // ✅ Update students list with fetched data
          students.value = fetchedStudents;
        } else {
          students.clear();
        }
      } else {
        students.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch students: $e");
    }
  }
}
