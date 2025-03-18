import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/attendance_controller.dart';

class CreateClassScreen extends StatefulWidget {
  final String? facultyPhoneNumber;

  CreateClassScreen({required this.facultyPhoneNumber});

  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classes");
  final AttendanceController _attendanceController =
      Get.put(AttendanceController());

  String? selectedStream, selectedSemester, selectedDivision, selectedSubject;
  List<Map<String, dynamic>> students = [];
  bool isFetching = false;

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
  List<String> divisions = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  // Define subjects for each stream and semester
  final Map<String, Map<String, List<String>>> streamSemesterSubjects = {
    'BCA': {
      'Semester 1': ['Maths', 'English', 'Programming'],
      'Semester 2': ['Data Structures', 'Discrete Maths', 'DBMS'],
      'Semester 3': ['Algorithms', 'Operating Systems', 'Web Development'],
      'Semester 4': ['Software Engineering', 'Networking', 'Java'],
      'Semester 5': ['Python', 'AI', 'Cloud Computing'],
      'Semester 6': ['Mobile App Development', 'Big Data', 'Cyber Security'],
      'Semester 7': ['Project Management', 'IoT', 'Blockchain'],
      'Semester 8': ['Capstone Project', 'Internship'],
    },
    'BBA': {
      'Semester 1': ['Principles of Management', 'Economics', 'Accounting'],
      'Semester 2': ['Business Law', 'Marketing', 'Financial Management'],
      'Semester 3': ['HR Management', 'Operations Management', 'Statistics'],
      'Semester 4': ['Entrepreneurship', 'Business Ethics', 'Taxation'],
      'Semester 5': [
        'Strategic Management',
        'International Business',
        'Banking'
      ],
      'Semester 6': [
        'Digital Marketing',
        'Supply Chain Management',
        'Auditing'
      ],
      'Semester 7': ['Project Work', 'Leadership', 'Consulting'],
      'Semester 8': ['Internship', 'Research Project'],
    },
    'B.COM': {
      'Semester 1': [
        'Financial Accounting',
        'Business Economics',
        'Business Law'
      ],
      'Semester 2': [
        'Corporate Accounting',
        'Statistics',
        'Business Communication'
      ],
      'Semester 3': ['Cost Accounting', 'Income Tax', 'Banking'],
      'Semester 4': ['Auditing', 'Management Accounting', 'Marketing'],
      'Semester 5': ['E-Commerce', 'Financial Management', 'HR Management'],
      'Semester 6': ['International Business', 'Entrepreneurship', 'Taxation'],
      'Semester 7': ['Project Work', 'Strategic Management', 'Consulting'],
      'Semester 8': ['Internship', 'Research Project'],
    },
  };

  List<String> getSubjects() {
    if (selectedStream != null &&
        selectedSemester != null &&
        streamSemesterSubjects.containsKey(selectedStream) &&
        streamSemesterSubjects[selectedStream]!.containsKey(selectedSemester)) {
      return streamSemesterSubjects[selectedStream]![selectedSemester]!;
    }
    return [];
  }

  Future<void> fetchStudents() async {
    if (selectedStream != null &&
        selectedSemester != null &&
        selectedDivision != null) {
      setState(() => isFetching = true);

      try {
        students = await _attendanceController.fetchStudents(
            selectedStream!, selectedSemester!, selectedDivision!);
        setState(() => isFetching = false);

        if (students.isNotEmpty) {
          Get.snackbar("Success", "Students fetched successfully!",
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar("Error", "No students found. Try again!",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        setState(() => isFetching = false);
        Get.snackbar("Error", "Failed to fetch students. Please try again!",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", "Please select stream, semester, and division.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveClass() async {
    if (students.isEmpty) {
      Get.snackbar("Error", "Fetch students before saving the class!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newClass = {
      'stream': selectedStream,
      'semester': selectedSemester,
      'division': selectedDivision,
      'subject': selectedSubject,
      'students': students,
      'facultyPhoneNumber': widget.facultyPhoneNumber,
    };

    await _dbRef.push().set(newClass);

    Get.snackbar("Success", "Class saved with students!",
        backgroundColor: Colors.green, colorText: Colors.white);

    Navigator.pop(context); // Navigate back to the faculty screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Class')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Stream'),
              items: streams.map((stream) {
                return DropdownMenuItem(value: stream, child: Text(stream));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStream = value;
                  selectedSemester = null; // Reset semester on stream change
                  selectedSubject = null; // Reset subject on stream change
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Semester'),
              items: semesters.map((sem) {
                return DropdownMenuItem(value: sem, child: Text(sem));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                  selectedSubject = null; // Reset subject on semester change
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Division'),
              items: divisions.map((div) {
                return DropdownMenuItem(value: div, child: Text(div));
              }).toList(),
              onChanged: (value) => setState(() => selectedDivision = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Subject'),
              items: getSubjects().map((subj) {
                return DropdownMenuItem(value: subj, child: Text(subj));
              }).toList(),
              onChanged: (value) => setState(() => selectedSubject = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchStudents,
              child: isFetching
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Fetch Students'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: students.isEmpty
                  ? Center(child: Text("No Students Found"))
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        var student = students[index];
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                              '${student['firstName']} ${student['lastName']}'),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: saveClass,
              child: Text('Save Class'),
            ),
          ],
        ),
      ),
    );
  }
}
