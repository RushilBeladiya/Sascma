import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/attendance_controller.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required stream});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController attendanceController =
      Get.put(AttendanceController());
  List<Map<String, dynamic>> students = [];

  String? selectedStream;
  String? selectedSemester;
  String? selectedDivision;

  List<String> streams = ['BCA', 'BBA', 'B.COM'];
  List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8'
  ];
  List<String> divisions = ['A', 'B', 'C', 'D'];

  Future<void> fetchStudents() async {
    if (selectedStream != null &&
        selectedSemester != null &&
        selectedDivision != null) {
      students = await attendanceController.fetchStudents(
          selectedStream!, selectedSemester!, selectedDivision!);
      setState(() {});
    } else {
      Get.snackbar("Error", "Please select stream, semester, and division.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedStream,
              onChanged: (value) {
                setState(() {
                  selectedStream = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Stream',
                border: OutlineInputBorder(),
              ),
              items: streams.map((String stream) {
                return DropdownMenuItem<String>(
                  value: stream,
                  child: Text(stream),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSemester,
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Semester',
                border: OutlineInputBorder(),
              ),
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDivision,
              onChanged: (value) {
                setState(() {
                  selectedDivision = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Division',
                border: OutlineInputBorder(),
              ),
              items: divisions.map((String division) {
                return DropdownMenuItem<String>(
                  value: division,
                  child: Text(division),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchStudents,
              child: Text('Fetch Students'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: students.isEmpty
                  ? Center(child: Text('No students found.'))
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text((student['data']['firstName'] ?? '') +
                              ' ' +
                              (student['data']['lastName'] ?? '')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  attendanceController.markAttendance(
                                      selectedStream!, student['id'], true);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  attendanceController.markAttendance(
                                      selectedStream!, student['id'], false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
