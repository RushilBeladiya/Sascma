import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/attendance_controller.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  _FacultyAttendanceScreenState createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  final AttendanceController attendanceController =
      Get.put(AttendanceController());
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> classes = [];

  String? selectedStream;
  String? selectedSemester;
  String? selectedDivision;
  String? selectedSubject;

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
  List<String> subjects = ['Math', 'Science', 'English'];

  Future<void> fetchStudents() async {
    if (selectedStream != null &&
        selectedSemester != null &&
        selectedDivision != null &&
        selectedSubject != null) {
      students = await attendanceController.fetchStudents(
          selectedStream!, selectedSemester!, selectedDivision!);
      setState(() {});
    } else {
      Get.snackbar("Error", "Please select all fields.");
    }
  }

  void _createClass() {
    if (selectedStream != null &&
        selectedSemester != null &&
        selectedDivision != null &&
        selectedSubject != null) {
      String classId = attendanceController.createClass(
          selectedStream!, selectedSemester!, selectedDivision!, students);
      Get.snackbar("Success", "Class created with ID: $classId");
    } else {
      Get.snackbar("Error", "Please select all fields.");
    }
  }

  Future<void> fetchClasses() async {
    classes = await attendanceController.fetchClasses();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Attendance'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createClass,
          ),
        ],
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
            DropdownButtonFormField<String>(
              value: selectedSubject,
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(),
              ),
              items: subjects.map((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
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
                          trailing: GestureDetector(
                            onTap: () {
                              attendanceController.markAttendance(
                                  selectedStream!, student['id'], true);
                            },
                            onDoubleTap: () {
                              attendanceController.markAttendance(
                                  selectedStream!, student['id'], false);
                            },
                            child: Icon(
                              Icons.circle,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.snackbar('Success', 'Attendance records submitted.');
              },
              child: Text('Submit Records'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: classes.isEmpty
                  ? Center(child: Text('No classes found.'))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classData = classes[index];
                        return ListTile(
                          title: Text(
                              '${classData['stream']} - ${classData['semester']} - ${classData['division']}'),
                          subtitle: Text('Class ID: ${classData['id']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              attendanceController.deleteClass(classData['id']);
                              fetchClasses();
                            },
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
