import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/Faculty/subject_controller.dart';
import '../../../core/utils/colors.dart';

// ignore: must_be_immutable
class PdfUploadScreen extends StatelessWidget {
  final PdfController pdfController = Get.put(PdfController());

  final TextEditingController subjectController = TextEditingController();
  String? selectedSemester;
  String? selectedStream;

  // Sample lists for semesters and streams
  final List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6'
  ];
  final List<String> streams = ['BCOM', 'BCA', 'BBA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor),
        backgroundColor: AppColor.primaryColor,
        title: Text('Upload PDF', style: TextStyle(color: AppColor.whiteColor)),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload PDF Document',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(subjectController, 'Subject'),
              SizedBox(height: 20),
              _buildDropdown('Select Semester', semesters, (newValue) {
                selectedSemester = newValue;
              }),
              SizedBox(height: 20),
              _buildDropdown('Select Stream', streams, (newValue) {
                selectedStream = newValue;
              }),
              SizedBox(height: 20),
              _buildSelectPdfButton(),
              SizedBox(height: 10),
              _buildUploadButton(),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Selected File: ${pdfController.fileName.value.isNotEmpty ? pdfController.fileName.value : "No file selected"}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }),
              if (pdfController.isLoading.value)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, Function(String?) onChanged) {
    // Debugging: print the list of items
    print('Dropdown items: $items');

    // Check for duplicates
    final Set<String> uniqueItems = items.toSet();
    if (uniqueItems.length != items.length) {
      print('Duplicate items detected in the dropdown: ${items}');
    }

    // Ensure that selected value is from the unique items
    String? currentValue =
        label == 'Select Semester' ? selectedSemester : selectedStream;
    if (currentValue != null && !uniqueItems.contains(currentValue)) {
      currentValue = null; // Reset if it is not found
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: uniqueItems.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (newValue) {
        onChanged(newValue);
        // Optionally update currentValue to track selected item
        if (label == 'Select Semester') {
          selectedSemester = newValue;
        } else if (label == 'Select Stream') {
          selectedStream = newValue;
        }
      },
      value: currentValue, // Set the current value here
    );
  }

  Widget _buildSelectPdfButton() {
    return ElevatedButton(
      onPressed: pdfController.pickFile,
      child: Text('Select PDF File'),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: () async {
        // Input validation
        if (subjectController.text.isEmpty) {
          Get.snackbar('Error', 'Please enter a subject.');
          return;
        }
        if (selectedSemester == null) {
          Get.snackbar('Error', 'Please select a semester.');
          return;
        }
        if (selectedStream == null) {
          Get.snackbar('Error', 'Please select a stream.');
          return;
        }
        if (pdfController.fileName.value.isNotEmpty) {
          // Upload the PDF if a file is selected
          await pdfController.uploadPdf(
            subjectController.text,
            selectedSemester ?? '',
            selectedStream ?? '',
          );
          // Clear fields after upload
          subjectController.clear();
          selectedSemester = null;
          selectedStream = null;
          pdfController.fileName.value = '';
          // Navigate back to the previous screen
          Get.back();
        } else {
          Get.snackbar('Error', 'Please select a PDF file first');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'Upload PDF',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
