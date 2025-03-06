import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/views/screens/student_screens/setting_screen/webview_screen.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../controller/Auth/auth_controller.dart';
import '../../../../controller/Student/home/student_home_controller.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/images.dart';
import '../home/contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StudentHomeController homeController = Get.find();
  AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      appBar: AppBar(
        leading: BackButton(color: AppColor.whiteColor),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            color: AppColor.blackColor.withOpacity(0.1),
            child: Row(
              children: [
                Obx(
                  () => homeController.isLoading.value
                      ? CircularProgressIndicator() // Show loading indicator
                      : CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppColor.whiteColor,
                          child: CircleAvatar(
                            radius: 38.r,
                            backgroundImage: homeController
                                    .currentStudent.value.profileImageUrl.isNotEmpty
                                ? NetworkImage(homeController
                                    .currentStudent.value.profileImageUrl)
                                : const AssetImage(AppImage.user)
                                    as ImageProvider,
                          ),
                        ),
                ),
                SizedBox(width: 15.w),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeController.currentStudent.value.firstName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackColor,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        homeController.currentStudent.value.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.blackColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          buildSettingsOption(Icons.info, 'About Us', () {
            Get.to(() => WebViewScreen(url: "", title: ""));
          }),
          buildSettingsOption(Icons.phone, 'Contact Us', () {
            Get.to(() => ContactUsScreen());
          }),
          buildSettingsOption(Icons.star_rate_rounded, 'Rate Us', () {}),
          buildSettingsOption(Icons.share, 'Share App', () {
            Share.share("Share CollegeApp");
          }),
          // if (homeController.checkAdminCredentials() == false)
          //   buildSettingsOption(Icons.delete_forever, 'Delete Account', () {
          //     _confirmDeleteAccount();
          //   }),
          buildSettingsOption(Icons.lock, 'Privacy Policy', () {
            // Get.to(() => PrivacyPolicyScreen());
          }),
          buildSettingsOption(Icons.security, 'Terms & Conditions', () {
            Get.to(() => TermsConditionsScreen());
          }),
        ],
      ),
    );
  }

  Widget buildSettingsOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 20.w),
      leading: Icon(
        icon,
        color: AppColor.primaryColor,
        size: 25.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Method to confirm account deletion
  void _confirmDeleteAccount() {
    Get.defaultDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.h),
      title: "Delete Account",
      titlePadding: EdgeInsets.only(top: 15.h),
      middleText:
          "Are you sure you want to delete your account? This action cannot be undone.",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: AppColor.primaryColor,
      backgroundColor: AppColor.appBackGroundColor,
      onConfirm: () async {
        // await authController.deleteUser(homeController.currentStudent.value.uid);
      },
    );
  }
}

// Placeholder for About Us screen
class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Text('About Us Screen'),
      ),
    );
  }
}

// Placeholder for Terms and Conditions screen
class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Text('Terms and Conditions Screen'),
      ),
    );
  }
}
