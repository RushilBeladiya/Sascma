import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/student_model.dart';
import '../../../views/screens/student_screens/home/bottom_navigation_screen/dash_board_screen.dart';
import '../../../views/screens/student_screens/home/bottom_navigation_screen/pending_screen.dart';
import '../../../views/screens/student_screens/home/bottom_navigation_screen/profile_screen.dart';
import '../../../views/screens/student_screens/setting_screen/settings_screen.dart';

class StudentHomeController extends GetxController {
  RxInt bottomScreenIndex = 2.obs;
  final FirebaseAuth authUser = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker picker = ImagePicker();
  var isLoading = false.obs;

  // void updatePaymentStatus(String paymentId, String status) {
  //   final paymentIndex = feePayments.indexWhere((payment) => payment.id == paymentId);
  //   if (paymentIndex != -1) {
  //     feePayments[paymentIndex].status = status;
  //     feePayments.refresh(); // Update the UI
  //   }
  // }

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('student');
  final DatabaseReference paymentRef =
      FirebaseDatabase.instance.ref().child('fee_payments');

  var feePayments = <FeePayment>[].obs;
  var currentStudent = StudentModel(
    uid: '',
    firstName: '',
    lastName: '',
    surName: '',
    spid: '',
    phoneNumber: '',
    email: '',
    stream: '',
    semester: '',
    division: '',
    profileImageUrl: '',
    attendance: [],
  ).obs;

  var attendanceReports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUserData();
    fetchFeePayments();
    fetchAttendanceReports();
    fetchCurrentUserAttendance(); // Fetch attendance records
  }

  final RxList bottomScreenList = [
    const ProfileScreen(),
    const PendingScreen(),
    const DashBoardScreen(),
    const PendingScreen(),
    const SettingsScreen(),
  ].obs;

  Future<void> uploadProfileImage(String uid) async {
    try {
      isLoading.value = true;

      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Upload to Firebase Storage
        String fileName = '$uid-profile-image.jpg';
        Reference ref = storage.ref().child('profile_images').child(fileName);

        UploadTask uploadTask = ref.putFile(imageFile);

        // Show circular progress while the upload is in progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // Here you can track the progress if needed
        });

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await firestore.collection('users').doc(uid).update({
          'profile_image_url': downloadUrl,
        });

        // userModel.update((user) {
        //   if (user != null) {
        //     user.profileImageUrl = downloadUrl;
        //   }
        // });
      }

      isLoading.value = false; // Set loading to false when upload finishes
    } catch (e) {
      isLoading.value = false; // Reset loading on error
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> fetchCurrentUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseEvent event = await dbRef.child(user.uid).once();
        if (event.snapshot.value != null) {
          var data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            currentStudent.value = StudentModel.fromMap(data);
            // Fetch attendance data
            DatabaseEvent attendanceEvent = await FirebaseDatabase.instance
                .ref()
                .child('attendance')
                .child(currentStudent.value.stream)
                .child(user.uid)
                .once();
            if (attendanceEvent.snapshot.value != null) {
              currentStudent.value.attendance =
                  (attendanceEvent.snapshot.value as Map<dynamic, dynamic>?)
                          ?.values
                          .map((e) => e as Map<String, dynamic>)
                          .toList() ??
                      [];
            }
            print(
                "User Loaded:----- ${currentStudent.value.firstName} ${currentStudent.value.lastName}");
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

  Future<void> fetchCurrentUserAttendance() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseEvent event = await FirebaseDatabase.instance
            .ref()
            .child('attendance')
            .child(user.uid)
            .once();

        if (event.snapshot.value != null) {
          currentStudent.value.attendance =
              (event.snapshot.value as Map<dynamic, dynamic>)
                  .values
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
        } else {
          currentStudent.value.attendance = [];
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance records: $e");
    }
  }

  Future<void> fetchFeePayments() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseEvent event = await paymentRef.child(user.uid).once();

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> paymentsData =
              event.snapshot.value as Map<dynamic, dynamic>;

          feePayments.value = paymentsData.entries.map((e) {
            final paymentId = e.key;
            final paymentData = e.value as Map<dynamic, dynamic>;

            return FeePayment(
              id: paymentId,
              amount: paymentData['amount'] ?? 0,
              status: paymentData['status'] ?? 'Unpaid',
            );
          }).toList();
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load fee payments: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await paymentRef.child(user.uid).child(paymentId).update({
          'status': status,
        });

        // Update local UI
        final paymentIndex =
            feePayments.indexWhere((payment) => payment.id == paymentId);
        if (paymentIndex != -1) {
          feePayments[paymentIndex].status = status;
          feePayments.refresh();
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update payment status: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void fetchAttendanceReports() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('attendance_reports')
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        attendanceReports.value = data.values
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance reports: $e");
    }
  }

  void trackLiveAttendance() {
    // Logic to track live attendance
    print("Tracking live attendance...");
  }

  void generateAttendanceReport(
      {String? date, String? subject, String? student}) {
    // Logic to generate attendance report based on date, subject, and student
    print("Generating attendance report...");
    if (date != null) {
      print("Filtering by date: $date");
    }
    if (subject != null) {
      print("Filtering by subject: $subject");
    }
    if (student != null) {
      print("Filtering by student: $student");
    }
  }
}

class FeePayment {
  final String id; // Dynamic payment ID
  final int amount;
  String status;

  FeePayment({required this.id, required this.amount, required this.status});
}
