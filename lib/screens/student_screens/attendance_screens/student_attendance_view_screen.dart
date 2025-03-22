import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controller/Student/home/student_home_controller.dart';

class StudentAttendanceViewScreen extends StatefulWidget {
  const StudentAttendanceViewScreen({super.key});

  @override
  _StudentAttendanceViewScreenState createState() =>
      _StudentAttendanceViewScreenState();
}

class _StudentAttendanceViewScreenState
    extends State<StudentAttendanceViewScreen> {
  final StudentHomeController studentHomeController = Get.find();
  RxMap<String, List<Map<String, dynamic>>> subjectWiseAttendance =
      <String, List<Map<String, dynamic>>>{}.obs;
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child('attendance');

  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        (picked.start != startDate || picked.end != endDate)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchAttendanceRecords();
    }
  }

  void fetchAttendanceRecords() async {
    try {
      String loggedInUserSpid = studentHomeController.currentStudent.value.spid;

      // Get the logged-in student's details
      String stream = studentHomeController.currentStudent.value.stream;
      String semester = studentHomeController.currentStudent.value.semester;
      String division = studentHomeController.currentStudent.value.division;

      if (loggedInUserSpid.isEmpty ||
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
            DateTime recordDate = DateFormat('yyyy-MM-dd').parse(dateKey);
            if (recordDate.isAfter(startDate) && recordDate.isBefore(endDate)) {
              Map<dynamic, dynamic> students =
              studentRecords as Map<dynamic, dynamic>;

              // Check if the student's SPID matches the logged-in user's SPID
              if (students.containsKey(loggedInUserSpid)) {
                var details = students[loggedInUserSpid];
                attendanceList.add({
                  'date': dateKey.replaceFirst('date_', ''), // Extract date
                  'status': details['status'] ?? 'Unknown',
                });
              }
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

  double calculateAttendancePercentage(List<Map<String, dynamic>> records) {
    int totalLectures = records.length;
    int presentCount =
        records.where((record) => record['status'] == 'present').length;
    return (presentCount / totalLectures) * 100;
  }

  int calculateTotalPresentLectures(List<Map<String, dynamic>> records) {
    return records.where((record) => record['status'] == 'present').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Report')),
      body: Obx(() {
        final student = studentHomeController.currentStudent.value;
        final attendanceData = subjectWiseAttendance;

        int overallTotalLectures = attendanceData.values
            .fold(0, (sum, records) => sum + records.length);
        int overallPresentLectures = attendanceData.values.fold(
            0, (sum, records) => sum + calculateTotalPresentLectures(records));
        double overallAttendancePercentage =
            (overallPresentLectures / overallTotalLectures) * 100;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: Text('Select Date Range'),
              ),
            ),

            // Overall Attendance Card with Radial Progress Bar
            Card(
              margin: EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Color(0xff3486d7), Color(0xff050a25)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Overall Attendance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Radial Progress Bar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        Container(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: RadialProgressPainter(
                              progress: overallAttendancePercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              progressColor: Colors.white,
                            ),
                          ),
                        ),
                        // Percentage Text
                        Text(
                          '${overallAttendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Total Lectures',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ), // Added missing closing parenthesis
                                ),
                                Text(
                                  '$overallTotalLectures',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Present Lectures',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ), // Added missing closing parenthesis
                                ),
                                Text(
                                  '$overallPresentLectures',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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

                  double attendancePercentage =
                  calculateAttendancePercentage(records);
                  int presentLectures =
                  calculateTotalPresentLectures(records);

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
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Total Lectures: ${records.length}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Present Lectures: $presentLectures',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 16),
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

class RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  RadialProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - 10;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -0.5 * 3.14, // Start angle (12 o'clock position)
      2 * 3.14 * progress, // Sweep angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}