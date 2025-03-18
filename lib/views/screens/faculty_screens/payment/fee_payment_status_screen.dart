import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Faculty/home/faculty_home_controller.dart';
import 'package:sascma/models/student_model.dart';

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
        title: const Text(
          'Fee Payment Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ Stream Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedStream.isEmpty ? null : selectedStream,
              hint: const Text('Select Stream'),
              isExpanded: true,
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
          ),

          // ✅ Fetch Students Button
          ElevatedButton(
            onPressed: () {
              if (selectedStream.isNotEmpty) {
                facultyHomeController.fetchStudentsByStream(selectedStream);
              } else {
                Get.snackbar("Error", "Please select a stream first!",
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text('Fetch Students'),
          ),
          const SizedBox(height: 10),

          // ✅ Student List (Paid & Unpaid Sections)
          Expanded(
            child: Obx(() {
              if (facultyHomeController.students.isEmpty) {
                return const Center(child: Text('No students found.'));
              }

              // Split students based on payment status
              var paidStudents = facultyHomeController.students
                  .where((student) => student.status == 'Paid')
                  .toList();
              var unpaidStudents = facultyHomeController.students
                  .where((student) => student.status != 'Paid')
                  .toList();

              return ListView(
                children: [
                  // ✅ Paid Students Section
                  if (paidStudents.isNotEmpty) ...[
                    _buildSectionHeader('Paid Students'),
                    _buildStudentList(paidStudents, true),
                  ],
                  // ✅ Unpaid Students Section
                  if (unpaidStudents.isNotEmpty) ...[
                    _buildSectionHeader('Unpaid Students'),
                    _buildStudentList(unpaidStudents, false),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ✅ Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  // ✅ Student List
  Widget _buildStudentList(List<StudentModel> students, bool isPaid) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isPaid ? Colors.green : Colors.orangeAccent, // Status color
              child: Icon(
                isPaid ? Icons.check_circle : Icons.info,
                color: Colors.white,
              ),
            ),
            title: Text(
              '${student.firstName} ${student.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ SPID Line
                Row(
                  children: [
                    Text(
                      'SPID: ${student.spid}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // Space between SPID and Stream

                // ✅ Stream Line
                Row(
                  children: [
                    Text(
                      'Stream: ${student.stream}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid ? Colors.green : Colors.red,
              ),
              child: Text(
                isPaid ? 'Success' : 'Unpaid',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
