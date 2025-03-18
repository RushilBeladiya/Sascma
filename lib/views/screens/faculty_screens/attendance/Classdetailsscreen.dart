import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  ClassDetailsScreen({required this.classData});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance records submitted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance: $e')),
      );
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
