import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sascma/controller/Auth/auth_controller.dart';

import 'add_event_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true; // ✅ Loading state
  bool _isStudent = false; // ✅ Student check

  @override
  void initState() {
    super.initState();
    _checkIfStudent(); // Check if the user is a student
    _fetchEvents();
  }

  /// ✅ Check if the user is a student
  Future<void> _checkIfStudent() async {
    _isStudent = await _authController.isStudent();
    setState(() {});
  }

  /// ✅ Fetch Events from Firestore
  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true); // Show loader
    try {
      final snapshot = await _firestore.collection('events').get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _events = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'],
              'date': data['date'],
              'faculty': data['faculty'],
              'pdfBase64': data['pdfBase64'],
            };
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch events: $e')),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loader
    }
  }

  /// ✅ Decode and Save PDF to Local Storage
  Future<String> _savePdfToLocal(String base64String, String fileName) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return '';
      }

      final bytes = base64Decode(base64String);

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/$fileName.pdf';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (await file.exists()) {
        return filePath;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save PDF')),
        );
        return '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
      return '';
    }
  }

  /// ✅ Open PDF Viewer
  Future<void> _openPdf(String base64String, String fileName) async {
    final filePath = await _savePdfToLocal(base64String, fileName);

    if (filePath.isNotEmpty) {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open PDF: ${result.message}')),
        );
      }
    }
  }

  /// ✅ Download PDF with Feedback
  Future<void> _downloadPdf(String base64String, String fileName) async {
    final filePath = await _savePdfToLocal(base64String, fileName);

    if (filePath.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to: $filePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No events available'))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          event['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '📅 Date: ${event['date']}\n👨‍🏫 Faculty: ${event['faculty']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// ✅ Open PDF Button
                            IconButton(
                              icon: const Icon(Icons.open_in_browser,
                                  color: Colors.blue),
                              onPressed: () => _openPdf(
                                event['pdfBase64'],
                                'Event_${event['id']}',
                              ),
                            ),

                            /// ✅ Download PDF Button
                            IconButton(
                              icon: const Icon(Icons.download,
                                  color: Colors.green),
                              onPressed: () => _downloadPdf(
                                event['pdfBase64'],
                                'Event_${event['id']}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      /// ✅ Conditionally render Floating Action Button
      floatingActionButton: _isStudent
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEventScreen(),
                  ),
                ).then((_) => _fetchEvents()); // Refresh event list
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
