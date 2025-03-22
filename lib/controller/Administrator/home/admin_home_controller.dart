import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/admin_Model.dart';
import '../../../models/faculty_model.dart';
import '../service/faculty_service.dart';

class AdminHomeController extends GetxController
{
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref().child('college_department');
  var facultyList = <FacultyModel>[].obs;
  var isLoading = false.obs;


  final DatabaseReference dbRefFaculty = FirebaseDatabase.instance.ref("faculty");
  var adminModel = AdminModel(
    uid: '',
    firstName: '',
    lastName: '',
    surName: '',
    phoneNumber: '',
    email: '',
    profileImageUrl: '',
  ).obs;



  @override
  void onInit() {
    fetchAdminData();
    fetchFacultyData();
    super.onInit();
  }


  Future<void> fetchAdminData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print("Fetching data for UID: ${user.uid}");

        DatabaseEvent event = await dbRef.child(user.uid).once();
        print("Raw Data: ${event.snapshot.value}");
        if (event.snapshot.value != null) {
          var data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            adminModel.value = AdminModel.fromMap(data);
            print("User Loaded: ${adminModel.value.firstName} ${adminModel.value.lastName}");
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

  Future<void> fetchFacultyData() async {
    try {
      isLoading.value = true;
      List<FacultyModel> data = await FacultyService.getFacultyList();
      facultyList.assignAll(data);
    } catch (e) {
      print("Error fetching faculty data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
