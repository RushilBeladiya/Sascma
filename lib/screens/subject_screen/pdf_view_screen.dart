import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sascma/core/utils/colors.dart'; // Import for file handling

class PdfViewScreen extends StatelessWidget {
  final String pdfUrl; // URL or local path of the PDF file

  const PdfViewScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'PDF View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColor.primaryColor,
        elevation: 10, // Elevation for a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30), // Rounded corners for the app bar
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: _loadPdf(), // Load the PDF before displaying
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading PDF: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No PDF found"));
          }

          // Debug log for PDF file path
          print('PDF file path: ${snapshot.data}');

          return Padding(
            padding: const EdgeInsets.all(8.0), // Padding around the PDF view
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20), // Rounded corners for the PDF view
              child: PDFView(
                filePath: snapshot.data!,
                enableSwipe: true, // Allow swipe gestures to change pages
                swipeHorizontal: true, // Enable horizontal swipe
                autoSpacing: true, // Automatically add spacing between pages
                pageFling: true, // Enable page flinging
                onPageChanged: (int? page, int? total) {
                  print('Page: $page of $total');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _loadPdf() async {
    // Check if the pdfUrl is valid and accessible
    if (Uri.parse(pdfUrl).isAbsolute) {
      return pdfUrl; // Return the PDF URL if it's valid
    } else if (File(pdfUrl).existsSync()) {
      return pdfUrl; // Return the local file path if it exists
    } else {
      throw Exception('Invalid PDF path: $pdfUrl');
    }
  }
}
