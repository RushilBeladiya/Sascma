import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/subject_pdf_model.dart';

class PdfController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<PdfDetail> pdfList = <PdfDetail>[].obs;
  var fileName = ''.obs;
  var selectedFilePath = ''.obs; // To store the selected file path
  var isLoading = false.obs; // Loading state variable

  // Fetch PDF details from Firestore
  Future<void> fetchPdfDetails() async {
    try {
      List<PdfDetail> fetchedPdfs = await fetchFromFirebase();
      pdfList.assignAll(fetchedPdfs); // Update the observable list
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch PDF details: ${e.toString()}');
    }
  }

  // Fetch from Firestore
  Future<List<PdfDetail>> fetchFromFirebase() async {
    List<PdfDetail> pdfDetailsList = [];

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('pdfs').get();

      for (var doc in querySnapshot.docs) {
        pdfDetailsList.add(PdfDetail(
          id: doc.id, // Make sure to add the document ID to the model
          name: doc['name'],
          url: doc['url'],
          semester: doc['semester'],
          subject: doc['subject'],
          stream: doc['stream'],
        ));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch data from Firebase: ${e.toString()}');
    }

    return pdfDetailsList;
  }

  // Upload PDF to Firebase
  Future<void> uploadPdf(String subject, String semester, String stream) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'User is not authenticated. Please log in.');
      return; // Exit if the user is not authenticated
    }

    if (selectedFilePath.value.isNotEmpty) {
      File file = File(selectedFilePath.value);

      if (file.existsSync()) {
        try {
          // Set loading state to true
          isLoading.value = true;

          // Extract the file name if it's not set
          if (fileName.value.isEmpty) {
            fileName.value = file.path.split('/').last;
          }

          // Upload the file
          await _storage.ref('pdfs/${user.uid}/${fileName.value}').putFile(file);

          // Save the file details in Firestore
          String downloadUrl = await _storage.ref('pdfs/${user.uid}/${fileName.value}').getDownloadURL();
          await _firestore.collection('pdfs').add({
            'name': fileName.value,
            'url': downloadUrl,
            'semester': semester,
            'subject': subject,
            'stream': stream,
          });

          Get.snackbar('Success', 'PDF uploaded successfully!');
          fetchPdfDetails(); // Refresh PDF list
        } catch (e) {
          Get.snackbar('Error', 'Failed to upload PDF: ${e.toString()}');
        } finally {
          isLoading.value = false; // Set loading state back to false
        }
      } else {
        Get.snackbar('Error', 'Selected file does not exist.');
      }
    } else {
      Get.snackbar('Error', 'No file selected for upload.');
    }
  }

  // Updated delete PDF method
  Future<void> deletePdf(String pdfId, String url) async {
    try {
      // Delete the PDF file from Firebase Storage
      await _storage.refFromURL(url).delete();

      // Remove the PDF entry from Firestore using the pdfId
      await _firestore.collection('pdfs').doc(pdfId).delete();

      // Refresh the PDF list after deletion
      await fetchPdfDetails(); // Re-fetch to update the list
      Get.snackbar('Success', 'PDF deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Could not delete PDF: $e');
    }
  }

  // Pick a file from the system
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      selectedFilePath.value = result.files.single.path ?? ''; // Set the selected file path
      fileName.value = result.files.single.name; // Store the file name
    } else {
      Get.snackbar('Error', 'No file selected');
    }
  }
}
