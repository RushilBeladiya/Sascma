import 'dart:convert'; // For Base64 encoding
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final DatabaseReference _eventsRef =
      FirebaseDatabase.instance.ref().child('events');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();

  File? _selectedPdf;
  String? _base64Pdf;
  bool _isUploading = false;

  /// ✅ Initialize Firebase Authentication
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// 🔥 Check if the User is Authenticated
  Future<void> _checkAuth() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to authenticate: $e')),
      );
    }
  }

  /// ✅ Select Date from Calendar
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  /// ✅ Select PDF File
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });

      /// Convert PDF to Base64
      _convertToBase64(_selectedPdf!);
    }
  }

  /// ✅ Convert PDF to Base64 String
  Future<void> _convertToBase64(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _base64Pdf = base64String;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF converted to Base64 successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to convert PDF: $e')),
      );
    }
  }

  /// ✅ Save Event with PDF Base64 to Firestore and Realtime Database
  void _saveEvent() async {
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _facultyController.text.isEmpty ||
        _base64Pdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select PDF')),
      );
      return;
    }

    final newEvent = {
      'name': _nameController.text,
      'date': _dateController.text,
      'faculty': _facultyController.text,
      'pdfBase64': _base64Pdf, // Store PDF as Base64 string
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      /// Store event in Firestore
      await _firestore.collection('events').add(newEvent);

      /// Store event in Realtime Database
      _eventsRef.push().set(newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// ✅ Event Name Field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              /// ✅ Date Field with Calendar Picker
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

              /// ✅ Faculty Field
              TextField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Faculty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              /// ✅ PDF Upload Section
              ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick PDF'),
              ),

              if (_selectedPdf != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected: ${_selectedPdf!.path.split('/').last}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              const SizedBox(height: 10),

              /// ✅ Save Event Button
              ElevatedButton.icon(
                onPressed: _base64Pdf != null ? _saveEvent : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),

      /// ✅ Floating Action Button for Saving the Event
      floatingActionButton: FloatingActionButton(
        onPressed: _saveEvent,
        child: const Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
