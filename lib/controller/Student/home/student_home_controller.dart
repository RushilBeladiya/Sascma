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

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('student');

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

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUserData();
    fetchFeePayments();
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

  void fetchFeePayments() {
    // Fetch fee payments from an API or database and populate the feePayments list
    feePayments.value = [
      FeePayment(amount: 2000, status: 'Unpaid'),
      // Add more fee payments as needed
    ];
  }
}

class FeePayment {
  final int amount;
  final String status;

  FeePayment({required this.amount, required this.status});
}
