import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sascma/core/utils/images.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;

import '../../../../core/utils/colors.dart';

class CollegeInfoScreen extends StatefulWidget {
  const CollegeInfoScreen({super.key});

  @override
  State<CollegeInfoScreen> createState() => _CollegeInfoScreenState();
}

class _CollegeInfoScreenState extends State<CollegeInfoScreen> {
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
    Share.share("Sascma Commerce College App");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor),
        backgroundColor: AppColor.primaryColor,
        title: Text(
          'College Info',
          style: TextStyle(color: AppColor.whiteColor, fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // College Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // College Image
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(AppImage.collegeImage),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),

                    // College Name
                    Text(
                      "Sascma English Medium Commerce College",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),

                    // College Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.red[700], size: 26),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            "5Q48+MWQ, Surat - Dumas Rd, Opp Govardhan Temple (Haveli), Vesu, Surat, Gujarat 395007",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Phone Number
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green[700], size: 26),
                        SizedBox(width: 10.w),
                        Text("+91 88666 61565",
                            style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Working Hours
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.orange[700], size: 26),
                        SizedBox(width: 10.w),
                        Text("Opens 7:30 am - Closes 4:00 pm",
                            style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Get Directions Button
            _buildButton(
              icon: Icons.directions,
              label: 'Get Directions',
              onPressed: _openMap,
              color: Colors.blue[400]!,
            ),

            SizedBox(height: 15.h),

            // Share App Button
            _buildButton(
              icon: Icons.share,
              label: 'Share App',
              onPressed: _shareApp,
              color: Colors.green[400]!,
            ),
          ],
        ),
      ),
    );
  }

  // Custom Button Widget
  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        style: TextStyle(fontSize: 16.sp),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
      ),
    );
  }
}
