import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/images.dart';

class CollegeInfoScreen extends StatefulWidget {
  const CollegeInfoScreen({super.key});

  @override
  State<CollegeInfoScreen> createState() => _CollegeInfoScreenState();
}

class _CollegeInfoScreenState extends State<CollegeInfoScreen> {
  // Function to open map
  // void _openMap() async {
  //   const url = 'https://www.google.com/maps/search/?api=1&query=Sascma+English+Medium+Commerce+College+Surat';
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  Future<void> _openMap() async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=Sascma+English+Medium+Commerce+College+Surat";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      print("Could not launch $googleMapsUrl");
    }
  }

  void _shareApp() {
    Share.share("Sascma Commerece College App");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor),
        backgroundColor: AppColor.primaryColor,
        title:
            Text('College Info', style: TextStyle(color: AppColor.whiteColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business profile section
            Card(
              elevation: 2,
              // color: AppColor.primaryColor.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Business Image
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            AppImage.collegeImage,
                          ),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Business Name
                    Text(
                      "Sascma English Medium Commerce College",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),

                    // Business Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[900]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "5Q48+MWQ, Surat - Dumas Rd, Opp Govardhan Temple (Haveli), Vesu, Surat, Gujarat 395007",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Phone Number
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.blue[900]),
                        SizedBox(width: 8),
                        Text("+91 88666 61565"),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Working Hours
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue[900]),
                        SizedBox(width: 8),
                        Text("Opens 7:30 am - Closes 4:00 pm"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Directions Button
            ElevatedButton.icon(
              onPressed: _openMap,
              icon: Icon(Icons.directions),
              label: Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                // Light blue button color
                foregroundColor: Colors.white, // Text color
              ),
            ),
            SizedBox(height: 10.h),

            // Share App Button
            ElevatedButton.icon(
              onPressed: _shareApp,
              icon: Icon(Icons.share),
              label: Text('Share App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                // Light blue button color
                foregroundColor: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
