import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/home/faculty_home_controller.dart';

class FeePaymentStatusScreen extends StatefulWidget {
  @override
  _FeePaymentStatusScreenState createState() => _FeePaymentStatusScreenState();
}

class _FeePaymentStatusScreenState extends State<FeePaymentStatusScreen> {
  final FacultyHomeController facultyHomeController = Get.find();
  String selectedStream = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Payment'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedStream.isEmpty ? null : selectedStream,
            hint: Text('Select Stream'),
            items: facultyHomeController.stream.map((stream) {
              return DropdownMenuItem<String>(
                value: stream,
                child: Text(stream),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStream = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedStream.isNotEmpty) {
                facultyHomeController.fetchStudentsByStream(selectedStream);
              }
            },
            child: Text('Fetch Students'),
          ),
          Expanded(
            child: Obx(() {
              if (facultyHomeController.students.isEmpty) {
                return Center(child: Text('No students found.'));
              }
              return ListView.builder(
                itemCount: facultyHomeController.students.length,
                itemBuilder: (context, index) {
                  final student = facultyHomeController.students[index];
                  return ListTile(
                    title: Text(
                        'Student Name: ${student.firstName} ${student.lastName}'),
                    subtitle: Text('Status: ${student.status}'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: student.status == 'Paid'
                            ? Colors.green
                            : Colors.red,
                      ),
                      child: Text(
                        student.status == 'Paid' ? 'Success' : 'Unpaid',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
