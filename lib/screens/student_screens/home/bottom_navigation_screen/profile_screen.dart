import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';
import 'package:sascma/core/utils/colors.dart';
import 'package:sascma/core/utils/images.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StudentHomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(color: AppColor.whiteColor),
        ),
        actions: [
          // if (homeController.checkAdminCredentials() == false)
          //   GestureDetector(
          //     onTap: () async {
          //       await Get.to(() => const EditProfileScreen());
          //     },
          //     child: Padding(
          //       padding: EdgeInsets.only(
          //         right: 15.w,
          //       ),
          //       child: Text(
          //         "Edit Profile",
          //         style: TextStyle(
          //           color: AppColor.whiteColor,
          //           fontSize: 12.sp,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        leading: BackButton(
          color: AppColor.whiteColor,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Obx(
          () => Column(
            children: [
              Card(
                elevation: 2,
                // color: AppColor.primaryColor.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 30.h,
                    horizontal: 25.w,
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => homeController.isLoading.value
                            ? CircularProgressIndicator() // Show loading indicator
                            : CircleAvatar(
                                radius: 50.r,
                                backgroundImage: homeController.currentStudent
                                        .value.profileImageUrl.isNotEmpty
                                    ? NetworkImage(homeController
                                        .currentStudent.value.profileImageUrl)
                                    : const AssetImage(AppImage.user)
                                        as ImageProvider,
                              ),
                      ),
                      SizedBox(height: 10.h),
                      Obx(
                        () => Text(
                          (homeController.currentStudent.value.firstName) ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      profileDetailRow('Mobile No',
                          (homeController.currentStudent.value.phoneNumber)),
                      profileDetailRow('Email Id',
                          (homeController.currentStudent.value.email)),
                      profileDetailRow('Session', '2024-2025'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.blackColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
