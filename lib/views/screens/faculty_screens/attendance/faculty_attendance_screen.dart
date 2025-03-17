import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sascma/controller/Faculty/attendance_controller.dart';
import 'package:sascma/controller/Faculty/home/faculty_home_controller.dart';
import 'package:sascma/models/faculty_model.dart';

class Faculty_AttendanceScreen extends StatefulWidget {
  @override
  _Faculty_AttendanceScreenState createState() =>
      _Faculty_AttendanceScreenState();
}

class _Faculty_AttendanceScreenState extends State<Faculty_AttendanceScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classes");
  final AttendanceController _attendanceController =
      Get.put(AttendanceController());
  final FacultyHomeController _facultyHomeController =
      Get.put(FacultyHomeController());
  bool isLoading = false; // Loader state
  String? facultyName;
  FacultyModel? currentFaculty;

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

  @override
  void initState() {
    super.initState();
    _facultyHomeController.fetchFacultyData();
  }

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

  Future<FacultyModel?> getFacultyByPhone(String phoneNumber) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("faculty");

    final snapshot = await ref.get();
    if (snapshot.exists) {
      Map<String, dynamic> facultyData =
          Map<String, dynamic>.from(snapshot.value as Map);

      for (var key in facultyData.keys) {
        var faculty = facultyData[key];

        if (faculty['phoneNumber'] == phoneNumber) {
          return FacultyModel.fromMap(Map<String, dynamic>.from(faculty));
        }
      }
    }
    return null; // Return null if not found
  }

  void _deleteClass(String classId) async {
    await _dbRef.child(classId).remove();
    Get.snackbar("Success", "Class deleted successfully",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _createClass() async {
    String? phoneNumber = _facultyHomeController.facultyModel.value.phoneNumber;

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar("Error", "Faculty is not logged in.");
      return;
    }

    FacultyModel? faculty = await getFacultyByPhone(phoneNumber);

    if (faculty == null) {
      Get.snackbar("Error", "Faculty details not found.");
      return;
    }

    // Step 3: Store faculty details
    facultyName = "${faculty.firstName} ${faculty.lastName} ${faculty.surName}";

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
                            'facultyName': facultyName,
                            'facultyPhoneNumber':
                                phoneNumber, // Store faculty phone number
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
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                              '${classData['stream']} - Semester ${classData['semester']}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Subject: ${classData['subject']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteClass(classData['key']),
                          ),
                          onTap: () => _openClassScreen(classData),
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
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void markAttendance(int index, bool isPresent) {
    setState(() {
      widget.classData['students'][index]['attendance'] =
          isPresent ? 'present' : 'absent';
    });

    String spid = widget.classData['students'][index]['spid']?.toString() ?? '';
    if (spid.isEmpty) {
      Get.snackbar("Error", "Student SPID is missing");
      return;
    }

    String date = DateFormat('yyyy-MM-dd').format(selectedDate);

    FirebaseDatabase.instance
        .ref()
        .child('attendance')
        .child(widget.classData['stream'])
        .child(widget.classData['semester'])
        .child(widget.classData['division'])
        .child(widget.classData['subject'])
        .child(date)
        .child(spid)
        .set({
      'status': isPresent ? 'Present' : 'Absent',
    });
  }

  void _confirmSubmission() async {
    try {
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      for (var student in widget.classData['students']) {
        String spid = student['spid']?.toString() ?? '';
        if (spid.isEmpty) {
          throw Exception("Student SPID is missing");
        }

        await FirebaseDatabase.instance
            .ref()
            .child('attendance')
            .child(widget.classData['stream'])
            .child(widget.classData['semester'])
            .child(widget.classData['division'])
            .child(widget.classData['subject'])
            .child(date)
            .child(spid)
            .set({
          'status': student['attendance'] ?? 'Absent',
        });
      }

      Get.back();
      Get.snackbar('Success', 'Attendance records submitted.');
    } catch (e) {
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
            child: Column(
              children: [
                Text(
                  'Subject: ${widget.classData['subject']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
                Text(
                  "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
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
