import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/views/screens/subject_screen/pdf_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/Faculty/subject_controller.dart';
import '../../../controller/Student/home/student_home_controller.dart';
import '../../../core/utils/colors.dart';

class PdfListScreen extends StatefulWidget {
  const PdfListScreen({super.key});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  final PdfController pdfController = Get.put(PdfController());
  final StudentHomeController homeController = Get.find();

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  void _deletePdf(String pdfId, String url) {
    pdfController.deletePdf(pdfId, url);
  }

  @override
  void initState() {
    super.initState();
    pdfController.fetchPdfDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor),
        backgroundColor: AppColor.primaryColor,
        title: Text('PDF', style: TextStyle(color: AppColor.whiteColor)),
        actions: [
          // if (homeController.checkAdminCredentials())
          //   IconButton(
          //     padding: EdgeInsets.only(right: 20.w),
          //     icon: Icon(
          //       Icons.cloud_upload_rounded,
          //       color: AppColor.whiteColor,
          //     ),
          //     onPressed: () =>
          //         Get.to(() => PdfUploadScreen()), // Navigate to Upload screen
          //   ),
        ],
      ),
      body: Obx(() {
        if (pdfController.pdfList.isEmpty) {
          return Center(child: Text("No PDFs Found"));
        }

        return ListView.builder(
          itemCount: pdfController.pdfList.length,
          itemBuilder: (context, index) {
            final pdfDetail = pdfController.pdfList[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListTile(
                onTap: () {
                  Get.to(() => PdfViewScreen(pdfUrl: pdfDetail.url));
                },
                title: Text(pdfDetail.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${pdfDetail.subject}'),
                    Text('Semester: ${pdfDetail.semester}'),
                    Text('Stream: ${pdfDetail.stream}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // if (homeController.checkAdminCredentials())
                    //   IconButton(
                    //     icon: Icon(Icons.download, color: Colors.blue),
                    //     onPressed: () => _launchURL(pdfDetail.url),
                    //   ),
                    // if (homeController.checkAdminCredentials())
                    //   IconButton(
                    //     icon: Icon(Icons.delete, color: Colors.red),
                    //     onPressed: () {
                    //       // Confirm deletion
                    //       Get.defaultDialog(
                    //         title: "Delete PDF",
                    //         middleText:
                    //             "Are you sure you want to delete this PDF?",
                    //         confirm: TextButton(
                    //           onPressed: () {
                    //             _deletePdf(pdfDetail.id,
                    //                 pdfDetail.url); // Adjust to your id field
                    //             Get.back(); // Close the dialog
                    //           },
                    //           child: Text("Yes"),
                    //         ),
                    //         cancel: TextButton(
                    //           onPressed: () => Get.back(), // Close the dialog
                    //           child: Text("No"),
                    //         ),
                    //       );
                    //     },
                    //   ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
