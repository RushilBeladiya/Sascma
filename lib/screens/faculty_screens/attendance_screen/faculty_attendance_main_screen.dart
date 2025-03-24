import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/core/utils/colors.dart';
import 'package:sascma/screens/faculty_screens/attendance_screen/faculty_attendance_taking_screen.dart';
import 'package:sascma/screens/faculty_screens/attendance_screen/faculty_class_create_screen.dart';

import '../../../../controller/Faculty/home/faculty_home_controller.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  @override
  _FacultyAttendanceScreenState createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classes");
  final FacultyHomeController _facultyHomeController =
      Get.put(FacultyHomeController());

  @override
  void initState() {
    super.initState();
    _facultyHomeController.fetchFacultyData();
  }

  void _deleteClass(String classId) async {
    await _dbRef.child(classId).remove();
    Get.snackbar("Success", "Class deleted successfully",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Manager',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primaryColor,
        elevation: 4,
      ),
      body: Container(
        color: AppColor.appBackGroundColor,
        child: Column(
          children: [
            Obx(() {
              if (_facultyHomeController.facultyModel.value.uid.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColor.primaryColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      "${_facultyHomeController.facultyModel.value.firstName} "
                      "${_facultyHomeController.facultyModel.value.lastName} "
                      "${_facultyHomeController.facultyModel.value.surName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phone: ${_facultyHomeController.facultyModel.value.phoneNumber}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Email: ${_facultyHomeController.facultyModel.value.email}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Class List Section
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        "No Classes Created",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  Map<String, dynamic> classMap = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);
                  List<Map<String, dynamic>> createdClasses =
                      classMap.entries.map((e) {
                    return {
                      'key': e.key,
                      ...Map<String, dynamic>.from(e.value)
                    };
                  }).toList();

                  // Filter classes by faculty phone number
                  createdClasses = createdClasses.where((classData) {
                    return classData['facultyPhoneNumber'] ==
                        _facultyHomeController.facultyModel.value.phoneNumber;
                  }).toList();

                  if (createdClasses.isEmpty) {
                    return const Center(
                      child: Text(
                        "No classes found for this faculty",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: createdClasses.length,
                    itemBuilder: (context, index) {
                      var classData = createdClasses[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: AppColor.primaryColor,
                              child:
                                  const Icon(Icons.school, color: Colors.white),
                            ),
                            title: Text(
                              '${classData['stream']} - ${classData['semester']}-${classData['division']}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Subject: ${classData['subject']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClass(classData['key']),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetailsScreen(
                                    classData: classData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateClassScreen(
                      facultyPhoneNumber:
                          _facultyHomeController.facultyModel.value.phoneNumber,
                    )),
          );
        },
        backgroundColor: AppColor.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
