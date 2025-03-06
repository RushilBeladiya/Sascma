import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('attendance');

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
}
