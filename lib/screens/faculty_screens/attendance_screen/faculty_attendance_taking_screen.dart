import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sascma/core/utils/colors.dart'; // Import your colors.dart

class ClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  ClassDetailsScreen({required this.classData});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  DateTime selectedDate = DateTime.now();
  Map<String, String> attendanceStatus = {};

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

  /// Select date
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
          backgroundColor: AppColor.successColor, // ✅ Success color
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit attendance: $e'),
          backgroundColor: AppColor.errorColor, // ✅ Error color
        ),
      );
    }
  }

  /// Color coding based on attendance status
  Color _getStatusColor(String status) {
    if (status == 'Present') return AppColor.successColor;
    if (status == 'Absent') return AppColor.errorColor;
    return AppColor.warningColor;
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentDate = isToday();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.classData['stream']} - Semester ${widget.classData['semester']} - Division ${widget.classData['division']}',
        ),
        backgroundColor: AppColor.primaryColor, // ✅ Primary color
        centerTitle: true,
      ),
      backgroundColor: AppColor.appBackGroundColor, // ✅ Background color
      body: Column(
        children: [
          // Date selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Subject: ${widget.classData['subject']}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor, // ✅ Text color
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text('Select Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor, // ✅ Primary color
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.textColor, // ✅ Text color
                  ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColor.warningColor, // ✅ Warning color
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.classData['students'].length,
                    itemBuilder: (context, index) {
                      var student = widget.classData['students'][index];
                      var firstName = student['firstName'] ?? 'Unknown';
                      var lastName = student['lastName'] ?? 'Unknown';
                      var spid = student['spid'] ?? 'N/A';

                      String status = attendanceStatus[spid] ?? 'Unmarked';
                      Color statusColor = _getStatusColor(status);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: AppColor.cardColor, // ✅ Card color
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColor.primaryColor,
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            '$firstName $lastName',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textColor,
                            ),
                          ),
                          subtitle: Text('SPID: $spid'),
                          trailing: isCurrentDate
                              ? Switch(
                                  value: status == 'Present',
                                  onChanged: (bool newValue) =>
                                      _toggleAttendance(spid),
                                  activeColor: AppColor.successColor,
                                  inactiveThumbColor: AppColor.errorColor,
                                  inactiveTrackColor: AppColor.warningColor,
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
                                    style: TextStyle(color: Colors.white),
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
                backgroundColor:
                    isCurrentDate ? AppColor.primaryColor : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
