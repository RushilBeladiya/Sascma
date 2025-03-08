import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('attendance');
  final DatabaseReference classRef =
      FirebaseDatabase.instance.ref().child('classes');

  Future<void> markAttendance(
      String stream, String studentId, bool isPresent) async {
    try {
      await dbRef.child(stream).child(studentId).set({
        'isPresent': isPresent,
        'timestamp': DateTime.now().toIso8601String(),
      });
      Get.snackbar("Success", "Attendance marked successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to mark attendance: $e");
    }
  }

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
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value['semester'] == semester && value['division'] == division) {
            students.add({
              'id': key,
              'data': value,
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch students: $e");
    }
    return students;
  }

  String createClass(String stream, String semester, String division,
      List<Map<String, dynamic>> students) {
    String classId = classRef.push().key!;
    classRef.child(classId).set({
      'stream': stream,
      'semester': semester,
      'division': division,
      'students': students,
    });
    return classId;
  }

  void deleteClass(String classId) {
    classRef.child(classId).remove();
  }

  Future<List<Map<String, dynamic>>> fetchClasses() async {
    List<Map<String, dynamic>> classes = [];
    try {
      DatabaseEvent event = await classRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          classes.add({
            'id': key,
            'stream': value['stream'],
            'semester': value['semester'],
            'division': value['division'],
          });
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch classes: $e");
    }
    return classes;
  }
}
