import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/home/faculty_home_controller.dart';
import 'package:sascma/views/screens/faculty_screens/attendance/Classdetailsscreen.dart';
import 'package:sascma/views/screens/faculty_screens/attendance/CreateClassScreen.dart';

class Faculty_AttendanceScreen extends StatefulWidget {
  @override
  _Faculty_AttendanceScreenState createState() =>
      _Faculty_AttendanceScreenState();
}

class _Faculty_AttendanceScreenState extends State<Faculty_AttendanceScreen> {
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
      appBar: AppBar(title: Text('Class Manager')),
      body: Column(
        children: [
          Obx(() {
            if (_facultyHomeController.facultyModel.value.uid.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Faculty: ${_facultyHomeController.facultyModel.value.firstName} ${_facultyHomeController.facultyModel.value.lastName} ${_facultyHomeController.facultyModel.value.surName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Phone: ${_facultyHomeController.facultyModel.value.phoneNumber}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Email: ${_facultyHomeController.facultyModel.value.email}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: StreamBuilder(
              stream: _dbRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Text("No Classes Created",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                }

                Map<String, dynamic> classMap = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);
                List<Map<String, dynamic>> createdClasses =
                    classMap.entries.map((e) {
                  return {'key': e.key, ...Map<String, dynamic>.from(e.value)};
                }).toList();

                // Filter classes based on the current faculty's phone number
                createdClasses = createdClasses.where((classData) {
                  return classData['facultyPhoneNumber'] ==
                      _facultyHomeController.facultyModel.value.phoneNumber;
                }).toList();

                return ListView.builder(
                  itemCount: createdClasses.length,
                  itemBuilder: (context, index) {
                    var classData = createdClasses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                              '${classData['stream']} - Semester ${classData['semester']}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Subject: ${classData['subject']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
