import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/models/faculty_model.dart';

class FacultyHomeController extends GetxController {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('faculty');
  var facultyModel = FacultyModel(
    uid: '',
    firstName: '',
    lastName: '',
    surName: '',
    phoneNumber: '',
    email: '',
    position: '',
    profileImageUrl: '',
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchFacultyData();
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
            facultyModel.value = FacultyModel.fromJson(data);
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
}
