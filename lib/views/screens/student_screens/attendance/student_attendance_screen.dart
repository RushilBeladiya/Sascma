import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreenState createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final StudentHomeController studentHomeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Obx(() {
        final attendance =
            studentHomeController.currentStudent.value.attendance;
        if (attendance == null || attendance.isEmpty) {
          return Center(child: Text('No attendance records found.'));
        }
        return ListView.builder(
          itemCount: attendance.length,
          itemBuilder: (context, index) {
            final record = attendance[index];
            return ListTile(
              title: Text(record['subject'] ?? ''),
              subtitle: Text(record['date'] ?? ''),
              trailing: Text(record['isPresent'] ? 'Present' : 'Absent'),
            );
          },
        );
      }),
    );
  }
}
