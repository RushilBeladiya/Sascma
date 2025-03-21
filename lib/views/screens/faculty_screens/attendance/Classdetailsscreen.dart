// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ClassDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> classData;

//   ClassDetailsScreen({required this.classData});

//   @override
//   _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
// }

// class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
//   DateTime selectedDate = DateTime.now();

//   /// Select Date - Restricted to past and current dates only
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(), // Restrict to past and current dates only
//     );

//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   /// Mark attendance for a student
//   void markAttendance(int index, bool isPresent) {
//     setState(() {
//       widget.classData['students'][index]['attendance'] =
//           isPresent ? 'present' : 'absent';
//     });

//     String spid = widget.classData['students'][index]['spid']?.toString() ?? '';
//     if (spid.isEmpty) return;

//     String date = DateFormat('yyyy-MM-dd').format(selectedDate);

//     FirebaseDatabase.instance
//         .ref()
//         .child('attendance')
//         .child(widget.classData['stream'])
//         .child(widget.classData['semester'])
//         .child(widget.classData['division'])
//         .child(widget.classData['subject'])
//         .child(date)
//         .child(spid)
//         .set({
//       'status': isPresent ? 'Present' : 'Absent',
//     });
//   }

//   /// Submit attendance records and navigate back to FacultyScreen
//   void _confirmSubmission() async {
//     try {
//       String date = DateFormat('yyyy-MM-dd').format(selectedDate);

//       for (var student in widget.classData['students']) {
//         String spid = student['spid']?.toString() ?? '';
//         if (spid.isEmpty) throw Exception("Student SPID is missing");

//         await FirebaseDatabase.instance
//             .ref()
//             .child('attendance')
//             .child(widget.classData['stream'])
//             .child(widget.classData['semester'])
//             .child(widget.classData['division'])
//             .child(widget.classData['subject'])
//             .child(date)
//             .child(spid)
//             .set({
//           'status': student['attendance'] ?? 'Absent',
//         });
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Attendance submitted successfully.'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate back to FacultyScreen
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to submit attendance: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '${widget.classData['stream']} - Semester ${widget.classData['semester']} - Division ${widget.classData['division']}',
//         ),
//         backgroundColor: Colors.blueAccent,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Date Selection Section
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text(
//                   'Subject: ${widget.classData['subject']}',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton.icon(
//                   onPressed: () => _selectDate(context),
//                   icon: Icon(Icons.calendar_today),
//                   label: Text('Select Date'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
//                   style: TextStyle(fontSize: 16, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),

//           // Students List Section
//           Expanded(
//             child: widget.classData['students'].isEmpty
//                 ? Center(
//                     child: Text(
//                       "No Students Found",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: widget.classData['students'].length,
//                     itemBuilder: (context, index) {
//                       var student = widget.classData['students'][index];
//                       var firstName = student['firstName'] ?? 'Unknown';
//                       var lastName = student['lastName'] ?? 'Unknown';
//                       var spid = student['spid'] ?? 'N/A';

//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.all(16),
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blueAccent,
//                             child: Text(
//                               firstName[0].toUpperCase(),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                           title: Text(
//                             '$firstName $lastName',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w600),
//                           ),
//                           subtitle: Text('SPID: $spid'),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(
//                                   Icons.check_circle,
//                                   color: student['attendance'] == 'present'
//                                       ? Colors.green
//                                       : Colors.grey,
//                                 ),
//                                 onPressed: () => markAttendance(index, true),
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   Icons.cancel,
//                                   color: student['attendance'] == 'absent'
//                                       ? Colors.red
//                                       : Colors.grey,
//                                 ),
//                                 onPressed: () => markAttendance(index, false),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),

//           // Submit Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton.icon(
//               onPressed: _confirmSubmission,
//               icon: Icon(Icons.save),
//               label: Text('Submit Records'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
  Map<String, String> attendanceStatus = {}; // Store attendance data

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  /// Fetch attendance from Firebase for the selected date
  Future<void> _fetchAttendance() async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('attendance')
        .child(widget.classData['stream'])
        .child(widget.classData['semester'])
        .child(widget.classData['division'])
        .child(widget.classData['subject'])
        .child(date);

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        attendanceStatus =
            data.map((key, value) => MapEntry(key, value['status']));
      });
    } else {
      setState(() {
        attendanceStatus.clear();
      });
    }
  }

  /// Select date - restrict to past and current dates only
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        attendanceStatus.clear();
      });
      _fetchAttendance();
    }
  }

  /// Check if the selected date is today's date
  bool isToday() {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  /// Toggle attendance (mark/unmark)
  void _toggleAttendance(String spid) {
    if (!isToday()) return;

    setState(() {
      if (attendanceStatus[spid] == 'Present') {
        attendanceStatus[spid] = 'Absent';
      } else {
        attendanceStatus[spid] = 'Present';
      }
    });
  }

  /// Submit attendance for today's date
  Future<void> _confirmSubmission() async {
    if (!isToday()) return;

    try {
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);

      for (var student in widget.classData['students']) {
        String spid = student['spid']?.toString() ?? '';
        if (spid.isEmpty) continue;

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
          'status': attendanceStatus[spid] ?? 'Absent',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Color coding based on attendance status
  Color _getStatusColor(String status) {
    if (status == 'Present') return Colors.green;
    if (status == 'Absent') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentDate = isToday();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.classData['stream']} - Semester ${widget.classData['semester']} - Division ${widget.classData['division']}',
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Subject: ${widget.classData['subject']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text('Select Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: widget.classData['students'].isEmpty
                ? Center(
                    child: Text(
                      "No Students Found",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.classData['students'].length,
                    itemBuilder: (context, index) {
                      var student = widget.classData['students'][index];
                      var firstName = student['firstName'] ?? 'Unknown';
                      var lastName = student['lastName'] ?? 'Unknown';
                      var spid = student['spid'] ?? 'N/A';

                      // Fetch attendance status or mark unmarked
                      String status = attendanceStatus[spid] ?? 'Unmarked';
                      Color statusColor = _getStatusColor(status);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            '$firstName $lastName',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('SPID: $spid'),
                          trailing: isCurrentDate
                              ? Switch(
                                  value: status == 'Present',
                                  onChanged: (bool newValue) =>
                                      _toggleAttendance(spid),
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  inactiveTrackColor: Colors.grey,
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: isCurrentDate ? _confirmSubmission : null,
              icon: Icon(Icons.save),
              label: Text('Submit Records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentDate ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
