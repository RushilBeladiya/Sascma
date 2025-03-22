import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/faculty_model.dart';

class AttendanceController extends GetxController {
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref().child('attendance');
  final DatabaseReference classRef =
  FirebaseDatabase.instance.ref().child('classes');

  // Mark attendance for a student
  Future<void> markAttendance(String stream, String semester, String division,
      String subjectId, String studentId, String spid, bool isPresent) async {
    try {
      String status = isPresent ? 'Present' : 'Absent';
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await dbRef
          .child(stream)
          .child(semester)
          .child(division)
          .child(subjectId)
          .child(date)
          .child(spid) // Use numeric SPID here
          .set({
        'status': status,
        'spid': spid, // Include numeric SPID in the record
      });

      Get.snackbar("Success", "Attendance marked successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to mark attendance: $e");
    }
  }

  // Edit attendance for a student
  Future<void> editAttendance(
      String stream, String studentId, bool isPresent) async {
    try {
      await dbRef.child(stream).child(studentId).update({
        'isPresent': isPresent,
        'timestamp': DateTime.now().toIso8601String(),
      });
      Get.snackbar("Success", "Attendance edited successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to edit attendance: $e");
    }
  }

  // Delete attendance for a student
  Future<void> deleteAttendance(String stream, String studentId) async {
    try {
      await dbRef.child(stream).child(studentId).remove();
      Get.snackbar("Success", "Attendance deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete attendance: $e");
    }
  }

  // Fetch students for a specific stream, semester, and division
  Future<List<Map<String, dynamic>>> fetchStudents(
      String stream, String semester, String division) async {
    List<Map<String, dynamic>> students = [];
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('student')
          .orderByChild('stream')
          .equalTo(stream)
          .once();

      if (event.snapshot.value != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data =
        event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value['semester'] == semester && value['division'] == division) {
            students.add({
              'id': key,
              'firstName': value['firstName'] ?? 'Unknown',
              'lastName': value['lastName'] ?? 'Student',
              'stream': value['stream'],
              'semester': value['semester'],
              'division': value['division'],
              'spid': value['spid'] ?? '', // Fetch numeric SPID
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch students: $e");
    }
    return students;
  }

  // Create a new class
  Future<String> createClass(String stream, String semester, String division,
      List<Map<String, dynamic>> students) async {
    try {
      String classId = classRef.push().key!;
      await classRef.child(classId).set({
        'stream': stream,
        'semester': semester,
        'division': division,
        'students': students
            .map((student) => {
          'id': student['id'],
          'firstName': student['firstName'],
          'lastName': student['lastName'],
          'stream': student['stream'],
          'semester': student['semester'],
          'division': student['division'],
          'spid': student['spid'], // Ensure numeric SPID is included
        })
            .toList(),
      });
      return classId;
    } catch (e) {
      throw Exception("Failed to create class: $e");
    }
  }

  // Fetch all classes
  Future<List<Map<String, dynamic>>> fetchClasses() async {
    List<Map<String, dynamic>> classes = [];
    try {
      DatabaseEvent event = await classRef.once();
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data =
        event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          classes.add({
            'id': key,
            'stream': value['stream'] ?? 'Unknown',
            'semester': value['semester'] ?? 'Unknown',
            'division': value['division'] ?? 'Unknown',
          });
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch classes: $e");
    }
    return classes;
  }

  // Submit attendance records for a class
  Future<void> submitAttendanceRecords(
      String stream,
      String semester,
      String division,
      String subjectId,
      List<Map<String, dynamic>> students) async {
    try {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var student in students) {
        String status = (student['attendance'] ?? 'Absent').toString();
        String studentId = student['id']?.toString() ?? '';
        String spid = student['spid']?.toString() ?? ''; // Fetch numeric SPID

        if (studentId.isEmpty || spid.isEmpty) {
          throw Exception("Student ID or SPID is missing");
        }

        await dbRef
            .child(stream)
            .child(semester)
            .child(division)
            .child(subjectId)
            .child(date)
            .child(spid)
            .set({
          'status': status,
          'spid': spid,
        });
      }

      Get.snackbar("Success", "Attendance records submitted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit attendance records: $e");
    }
  }

  // Fetch attendance records for a specific subject
  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(
      String stream, String semester, String division, String subjectId) async {
    List<Map<String, dynamic>> records = [];
    try {
      DatabaseEvent event = await dbRef
          .child(stream)
          .child(semester)
          .child(division)
          .child(subjectId)
          .once();

      if (event.snapshot.value != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data =
        event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((date, attendance) {
          if (attendance is Map<dynamic, dynamic>) {
            attendance.forEach((spid, record) {
              records.add({
                'date': date,
                'spid': spid.toString(),
                'status': record['status'],
              });
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance records: $e");
    }
    return records;
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
          return FacultyModel.fromJson(Map<String, dynamic>.from(faculty));
        }
      }
    }
    return null; // Return null if not found
  }
}