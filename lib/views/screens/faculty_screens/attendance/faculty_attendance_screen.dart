import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sascma/controller/Faculty/attendance_controller.dart';

class Faculty_AttendanceScreen extends StatefulWidget {
  @override
  _Faculty_AttendanceScreenState createState() =>
      _Faculty_AttendanceScreenState();
}

class _Faculty_AttendanceScreenState extends State<Faculty_AttendanceScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classes");
  final AttendanceController _attendanceController =
      Get.put(AttendanceController());
  bool isLoading = false; // Loader state

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
      students = await _attendanceController.fetchStudents(
          selectedStream!, selectedSemester!, selectedDivision!);
      setState(() {});
    } else {
      Get.snackbar("Error", "Please select stream, semester, and division.");
    }
  }

  void _deleteClass(String classId) {
    _attendanceController.deleteClass(classId);
    Get.snackbar("Success", "Class deleted successfully");
  }

  void _createClass() {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStream,
            selectedSemester,
            selectedDivision,
            selectedSubject;
        List<Map<String, dynamic>> students = [];
        bool isFetching = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Create Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Stream'),
                      items: streams.map((stream) {
                        return DropdownMenuItem(
                            value: stream, child: Text(stream));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedStream = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Semester'),
                      items: semesters.map((sem) {
                        return DropdownMenuItem(value: sem, child: Text(sem));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedSemester = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Division'),
                      items: divisions.map((div) {
                        return DropdownMenuItem(value: div, child: Text(div));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedDivision = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Subject'),
                      items: ['Maths', 'English', 'Gujarati'].map((subj) {
                        return DropdownMenuItem(value: subj, child: Text(subj));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedSubject = value),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedStream != null &&
                            selectedSemester != null &&
                            selectedDivision != null) {
                          setStateDialog(
                              () => isFetching = true); // Show loader

                          try {
                            students =
                                await _attendanceController.fetchStudents(
                              selectedStream!,
                              selectedSemester!,
                              selectedDivision!,
                            );
                            setStateDialog(() => isFetching = false);

                            if (students.isNotEmpty) {
                              Get.snackbar(
                                  "Success", "Students fetched successfully!",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white);
                            } else {
                              Get.snackbar(
                                  "Error", "No students found. Try again!",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            }
                          } catch (e) {
                            setStateDialog(() => isFetching = false);
                            Get.snackbar("Error",
                                "Failed to fetch students. Please try again!",
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                          }
                        }
                      },
                      child: isFetching
                          ? CircularProgressIndicator(
                              color: Colors.white) // Loader
                          : Text('Fetch Students'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: students.isNotEmpty
                      ? () async {
                          final newClass = {
                            'stream': selectedStream,
                            'semester': selectedSemester,
                            'division': selectedDivision,
                            'subject': selectedSubject,
                            'students': students,
                          };

                          await _dbRef.push().set(newClass);

                          Get.snackbar("Success", "Class saved with students!",
                              backgroundColor: Colors.green,
                              colorText: Colors.white);

                          Navigator.pop(context);
                        }
                      : () {
                          Get.snackbar("Error",
                              "Fetch students before saving the class!",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        },
                  child: Text('Save Class'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editClass(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStream = classData['stream'],
            selectedSemester = classData['semester'],
            selectedDivision = classData['division'],
            selectedSubject = classData['subject'];
        List<Map<String, dynamic>> students = classData['students'];
        bool isFetching = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Stream'),
                      value: selectedStream,
                      items: streams.map((stream) {
                        return DropdownMenuItem(
                            value: stream, child: Text(stream));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedStream = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Semester'),
                      value: selectedSemester,
                      items: semesters.map((sem) {
                        return DropdownMenuItem(value: sem, child: Text(sem));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedSemester = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Division'),
                      value: selectedDivision,
                      items: divisions.map((div) {
                        return DropdownMenuItem(value: div, child: Text(div));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedDivision = value),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Subject'),
                      value: selectedSubject,
                      items: ['Maths', 'English', 'Gujarati'].map((subj) {
                        return DropdownMenuItem(value: subj, child: Text(subj));
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedSubject = value),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedStream != null &&
                            selectedSemester != null &&
                            selectedDivision != null) {
                          setStateDialog(
                              () => isFetching = true); // Show loader

                          try {
                            students =
                                await _attendanceController.fetchStudents(
                              selectedStream!,
                              selectedSemester!,
                              selectedDivision!,
                            );
                            setStateDialog(() => isFetching = false);

                            if (students.isNotEmpty) {
                              Get.snackbar(
                                  "Success", "Students fetched successfully!",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white);
                            } else {
                              Get.snackbar(
                                  "Error", "No students found. Try again!",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            }
                          } catch (e) {
                            setStateDialog(() => isFetching = false);
                            Get.snackbar("Error",
                                "Failed to fetch students. Please try again!",
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                          }
                        }
                      },
                      child: isFetching
                          ? CircularProgressIndicator(
                              color: Colors.white) // Loader
                          : Text('Fetch Students'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: students.isNotEmpty
                      ? () async {
                          final updatedClass = {
                            'stream': selectedStream,
                            'semester': selectedSemester,
                            'division': selectedDivision,
                            'subject': selectedSubject,
                            'students': students,
                          };

                          await _dbRef
                              .child(classData['key'])
                              .update(updatedClass);

                          Get.snackbar("Success", "Class updated successfully!",
                              backgroundColor: Colors.green,
                              colorText: Colors.white);

                          Navigator.pop(context);
                        }
                      : () {
                          Get.snackbar("Error",
                              "Fetch students before updating the class!",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        },
                  child: Text('Update Class'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openClassScreen(Map<String, dynamic> classData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClassScreen(classData: classData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Class Manager')),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text("No Classes Created",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          Map<String, dynamic> classMap =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          List<Map<String, dynamic>> createdClasses = classMap.entries.map((e) {
            return {'key': e.key, ...Map<String, dynamic>.from(e.value)};
          }).toList();

          return ListView.builder(
            itemCount: createdClasses.length,
            itemBuilder: (context, index) {
              var classData = createdClasses[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Text(
                        '${classData['stream']} - Semester ${classData['semester']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Subject: ${classData['subject']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editClass(classData),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteClass(classData['key']),
                        ),
                      ],
                    ),
                    onTap: () => _openClassScreen(classData),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createClass();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ClassScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  ClassScreen({required this.classData});

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final AttendanceController _attendanceController =
      Get.put(AttendanceController());

  void markAttendance(int index, bool isPresent) {
    setState(() {
      widget.classData['students'][index]['attendance'] =
          isPresent ? 'present' : 'absent';
    });

    String studentId =
        widget.classData['students'][index]['id']?.toString() ?? '';
    if (studentId.isEmpty) {
      Get.snackbar("Error", "Student ID is missing");
      return;
    }

    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    FirebaseDatabase.instance
        .ref()
        .child('attendance')
        .child(studentId)
        .child(widget.classData['stream'])
        .child(widget.classData['semester'])
        .child(widget.classData['division'])
        .child(widget.classData['subject'])
        .child('date_$date')
        .child('spid_$studentId') // Use spid here
        .set({
      'userid': studentId,
      'name':
          '${widget.classData['students'][index]['firstName']} ${widget.classData['students'][index]['lastName']}',
      'status': isPresent ? 'Present' : 'Absent',
    });
  }

  void _confirmSubmission() async {
    try {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      List<Map<String, dynamic>> studentRecords =
          (widget.classData['students'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      for (var student in studentRecords) {
        String studentId = student['id']?.toString() ?? '';
        if (studentId.isEmpty) {
          throw Exception("Student ID is missing");
        }

        await FirebaseDatabase.instance
            .ref()
            .child('attendance')
            .child(studentId)
            .child(widget.classData['stream'])
            .child(widget.classData['semester'])
            .child(widget.classData['division'])
            .child(widget.classData['subject'])
            .child('date_$date')
            .child('spid_$studentId') // Use spid here
            .set({
          'name': '${student['firstName']} ${student['lastName']}',
          'userid': studentId,
          'status': student['attendance'] ?? 'Absent',
        });
      }

      Get.back();

      // Show success message
      Get.snackbar('Success', 'Attendance records submitted.');
    } catch (e) {
      // Close the loading dialog if submission fails
      Get.back();
      Get.snackbar('Error', 'Failed to submit attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.classData['stream']} - Semester ${widget.classData['semester']} - Division ${widget.classData['division']}',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Subject: ${widget.classData['subject']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: widget.classData['students'].isEmpty
                ? Center(
                    child: Text(
                      "No Students Found",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.classData['students'].length,
                    itemBuilder: (context, index) {
                      var student = widget.classData['students'][index];
                      var firstName = student['firstName'] ?? 'Unknown';
                      var lastName = student['lastName'] ?? 'Unknown';
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text('$firstName $lastName'),
                        trailing: GestureDetector(
                          onTap: () => markAttendance(index, true),
                          onDoubleTap: () => markAttendance(index, false),
                          child: Icon(
                            Icons.circle,
                            color: student['attendance'] == 'present'
                                ? Colors.green
                                : student['attendance'] == 'absent'
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: _confirmSubmission,
            child: Text('Submit Records'),
          ),
        ],
      ),
    );
  }
}
