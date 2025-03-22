import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/models/faculty_model.dart';
import 'package:sascma/models/student_model.dart';
import 'package:sascma/screens/administrator_screens/home/admin_home_screen.dart';
import 'package:sascma/screens/auth_screen/student_auth_screen/student_login_screen.dart';
import 'package:sascma/screens/auth_screen/student_auth_screen/student_registration_screen.dart';
import 'package:sascma/screens/faculty_screens/home/faculty_home_screen.dart';
import 'package:sascma/screens/student_screens/home/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference dbRefStudent =
      FirebaseDatabase.instance.ref().child('student');
  final DatabaseReference dbRefAdmin =
      FirebaseDatabase.instance.ref().child('college_department');
  final DatabaseReference dbRefFaculty =
      FirebaseDatabase.instance.ref().child('faculty');

  var isEmailVerified = false.obs;
  var isTimerRunning = false.obs;
  var remainingSeconds = 90.obs;
  Timer? timer;

  // Future<void> loginStudent(String email, String spid) async {
  //   try {
  //     UserCredential userCredential = await auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: spid, // Assuming SPID is the password
  //     );
  //
  //     User? user = userCredential.user;
  //     if (user != null) {
  //       isEmailVerified.value = user.emailVerified;
  //       if (!isEmailVerified.value) {
  //         sendVerificationEmail();
  //         startTimer();
  //       } else {
  //         Get.snackbar("Success", "Login Successful");
  //         // Navigate to dashboard
  //       }
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", e.toString());
  //   }
  // }

  void sendVerificationEmail() async {
    try {
      User? user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar("Verification", "Verification email sent!");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void startTimer() {
    remainingSeconds.value = 60;
    isTimerRunning.value = true;

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isTimerRunning.value = false;
        timer.cancel();
      }
    });
  }

  void checkEmailVerification() async {
    await auth.currentUser?.reload();
    isEmailVerified.value = auth.currentUser?.emailVerified ?? false;
  }

  Future<void> saveStudentData(
      String uid,
      String firstName,
      String lastName,
      String surName,
      String spid,
      String phoneNumber,
      String email,
      String stream,
      String semester,
      String division) async {
    StudentModel user = StudentModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      surName: surName,
      spid: spid,
      phoneNumber: phoneNumber,
      email: email,
      stream: stream,
      semester: semester,
      division: division,
      profileImageUrl: "",
    );
    await dbRefStudent.child(uid).set(user.toMap());
  }

  Future<void> registerStudent(
    String firstName,
    String lastName,
    String surName,
    String spid,
    String phoneNumber,
    String email,
    String stream,
    String semester,
    String division,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: spid,
      );

      String uid = userCredential.user!.uid;

      await saveStudentData(
        uid,
        firstName,
        lastName,
        surName,
        spid,
        phoneNumber,
        email,
        stream,
        semester,
        division,
      );

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('isLoggedIn', true);
      // await prefs.setString('userToken', uid);
      //
      Get.back();
    } catch (e) {
      Get.snackbar("Registration Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e);
    }
  }

  Future<void> saveFacultyData(String uid, String firstName, String lastName,
      String surName, String phoneNumber, String email, String position) async {
    FacultyModel user = FacultyModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      surName: surName,
      phoneNumber: phoneNumber,
      email: email,
      position: position,
      profileImageUrl: "",
    );
    await dbRefFaculty.child(uid).set(user.toMap());
  }

  Future<void> registerFaculty(
    String firstName,
    String lastName,
    String surName,
    String phoneNumber,
    String email,
    String position,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: phoneNumber,
      );

      String uid = userCredential.user!.uid;

      await saveFacultyData(
        uid,
        firstName,
        lastName,
        surName,
        phoneNumber,
        email,
        position,
      );

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('isLoggedIn', true);
      // await prefs.setString('userToken', uid);
      //
      Get.back();
    } catch (e) {
      Get.snackbar("Registration Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e);
    }
  }

  Future<void> loginStudent(String email, String spid) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Query the database to verify both email and SPID
      var query = dbRefStudent.orderByChild('email').equalTo(email);
      DatabaseEvent event = await query.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> userData =
            event.snapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> user = userData.values.first;

        // Verify the SPID matches
        if (user['spid'] == spid) {
          UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: spid,
          );

          String uid = userCredential.user!.uid;

          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // await prefs.setBool('isLoggedIn', true);
          // await prefs.setString('userToken', uid);

          Get.offAll(() => HomeScreen());
        } else {
          Get.snackbar("Error", "SPID does not match.");
        }
      } else {
        Get.snackbar("Error", "Email not found.");
      }
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
      print(e);
    }
  }

  Future<void> loginAdminAndFaculty(String email, String phoneNumber) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Check Admin database
      var adminQuery = dbRefAdmin.orderByChild('email').equalTo(email);
      DatabaseEvent adminEvent = await adminQuery.once();

      // Check Faculty database
      var facultyQuery = dbRefFaculty.orderByChild('email').equalTo(email);
      DatabaseEvent facultyEvent = await facultyQuery.once();

      if (adminEvent.snapshot.exists) {
        Map<dynamic, dynamic> adminData =
            adminEvent.snapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> admin = adminData.values.first;

        if (admin['phoneNumber'] == phoneNumber) {
          UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: phoneNumber, // Use the entered phone number as password
          );

          String uid = userCredential.user!.uid;
          Get.offAll(() => AdminHomeScreen()); // Navigate to Admin Dashboard
        } else {
          Get.snackbar("Login Error", "Incorrect phone number (password).");
        }
      } else if (facultyEvent.snapshot.exists) {
        // Faculty found, get data
        Map<dynamic, dynamic> facultyData =
            facultyEvent.snapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> faculty = facultyData.values.first;

        if (faculty['phoneNumber'] == phoneNumber) {
          UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: phoneNumber,
          );
          String uid = userCredential.user!.uid;
          Get.offAll(() => FacultyHomeScreen());
        } else {
          Get.snackbar("Login Error", "Incorrect phone number (password).");
        }
      } else {
        Get.snackbar("Error", "Email not found.");
      }
    } catch (e) {
      Get.snackbar("Login Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e);
    }
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('isLoggedIn', false);
    // prefs.remove('userToken');

    Get.offAll(() => const StudentLoginScreen());
  }

  Future<void> deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }

      // Navigate to the registration screen
      Get.offAll(() => StudentRegistrationScreen());

      Get.snackbar("Success", "User deleted successfully",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
