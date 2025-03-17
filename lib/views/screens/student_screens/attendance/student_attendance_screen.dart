import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

class StudentAttendanceReportScreen extends StatefulWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  _StudentAttendanceReportScreenState createState() =>
      _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState
    extends State<StudentAttendanceReportScreen> {
  final StudentHomeController studentHomeController = Get.find();
  RxMap<String, List<Map<String, dynamic>>> subjectWiseAttendance =
      <String, List<Map<String, dynamic>>>{}.obs;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('attendance');

  // Static UID
  final String staticUid = "Cj5MAsU62CalEEoiawekgHbKNdG3";

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  void fetchAttendanceRecords() async {
    try {
      // Use the static UID instead of fetching from the controller
      String loggedInUserId = staticUid;

      // Get the logged-in student's details
      String stream = studentHomeController.currentStudent.value.stream ?? "";
      String semester =
          studentHomeController.currentStudent.value.semester ?? "";
      String division =
          studentHomeController.currentStudent.value.division ?? "";

      if (loggedInUserId.isEmpty ||
          stream.isEmpty ||
          semester.isEmpty ||
          division.isEmpty) {
        Get.snackbar("Error", "Student details are missing.");
        return;
      }

      // Fetch attendance data for the logged-in student
      DatabaseEvent event =
          await _dbRef.child(stream).child(semester).child(division).once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> subjects =
            event.snapshot.value as Map<dynamic, dynamic>;

        Map<String, List<Map<String, dynamic>>> groupedAttendance = {};

        subjects.forEach((subjectName, dates) {
          Map<dynamic, dynamic> dateRecords = dates as Map<dynamic, dynamic>;

          List<Map<String, dynamic>> attendanceList = [];

          dateRecords.forEach((dateKey, studentRecords) {
            Map<dynamic, dynamic> students =
                studentRecords as Map<dynamic, dynamic>;

            // Check if the student's ID matches the static UID
            if (students.containsKey(loggedInUserId)) {
              var details = students[loggedInUserId];
              attendanceList.add({
                'date': dateKey.replaceFirst('date_', ''), // Extract date
                'status': details['status'] ?? 'Unknown',
              });
            }
          });

          if (attendanceList.isNotEmpty) {
            groupedAttendance[subjectName] = attendanceList;
          }
        });

        subjectWiseAttendance.value = groupedAttendance;
      } else {
        Get.snackbar("Info", "No attendance records found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance records: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Report')),
      body: Obx(() {
        final student = studentHomeController.currentStudent.value;
        final attendanceData = subjectWiseAttendance;

        return Column(
          children: [
            // Student Info Card
            Card(
              margin: EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student Details',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent)),
                        Icon(Icons.person, color: Colors.blueAccent),
                      ],
                    ),
                    Divider(),
                    Text('Name: ${student.firstName} ${student.lastName}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('ID: $staticUid', // Display the static UID
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text('Stream: ${student.stream}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text('Semester: ${student.semester}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text('Division: ${student.division}',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ),
            ),

            // Attendance List
            Expanded(
              child: attendanceData.isEmpty
                  ? Center(child: Text('No attendance records found.'))
                  : ListView.builder(
                      itemCount: attendanceData.length,
                      itemBuilder: (context, index) {
                        String subject = attendanceData.keys.elementAt(index);
                        List<Map<String, dynamic>> records =
                            attendanceData[subject]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                  ),
                                  child: Text(
                                    subject,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                ),
                                Column(
                                  children: records.map((record) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                record['status'] == 'present'
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: record['status'] ==
                                                        'present'
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                '🗓 Date: ${record['date']}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            record['status'] == 'present'
                                                ? '✅ Present'
                                                : '❌ Absent',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: record['status'] ==
                                                        'present'
                                                    ? Colors.green
                                                    : Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
