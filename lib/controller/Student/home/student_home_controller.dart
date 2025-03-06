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

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUserData();
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

  // void fetchUserData() async {
  //   try {
  //     String uid = authUser.currentUser!.uid;
  //     DocumentSnapshot userDoc =
  //         await FirebaseFirestore.instance.collection('users').doc(uid).get();
  //
  //     userModel.value = StudentModel.fromFirestore(userDoc);
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to fetch user data: $e");
  //   }
  // }

  // Future<void> updateUserData(String username) async {
  //   String uid = userModel.value.uid;
  //   try {
  //     if (username != userModel.value.firstName) {
  //       await FirebaseFirestore.instance.collection('users').doc(uid).update({
  //         'username': username,
  //       });
  //       fetchUserData();
  //       await Fluttertoast.showToast(
  //           msg: "Update successful", toastLength: Toast.LENGTH_LONG);
  //       Get.back();
  //     } else {
  //       await Fluttertoast.showToast(
  //           msg: "Your username is same!!!", toastLength: Toast.LENGTH_LONG);
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to update profile: $e");
  //   }
  // }

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
}
