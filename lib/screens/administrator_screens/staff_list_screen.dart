import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Administrator/home/admin_home_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/colors.dart';
import '../../../models/faculty_model.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final AdminHomeController adminHomeController = Get.find();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    await adminHomeController.fetchFacultyData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Staff List", style: TextStyle(color: AppColor.whiteColor)),
        backgroundColor: AppColor.primaryColor,
        leading: BackButton(
          color: AppColor.whiteColor,
        ),
      ),
      body: Obx(() {
        if (adminHomeController.isLoading.value) {
          return _buildShimmerEffect();
        }

        if (adminHomeController.facultyList.isEmpty) {
          return const Center(child: Text("No Faculty Data Available"));
        }

        return RefreshIndicator(
          backgroundColor: AppColor.appBackGroundColor,
          color: AppColor.primaryColor,
          onRefresh: () async {
            await adminHomeController.fetchFacultyData();
          },
          child: ListView.builder(
            itemCount: adminHomeController.facultyList.length,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemBuilder: (context, index) {
              FacultyModel faculty = adminHomeController.facultyList[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundColor: AppColor.greyColor,
                      backgroundImage: faculty.profileImageUrl.isNotEmpty
                          ? NetworkImage(faculty.profileImageUrl)
                          : const AssetImage("assets/dashboard/user.png")
                              as ImageProvider,
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "${faculty.firstName.toUpperCase()} ${faculty.lastName.toUpperCase()} ${faculty.surName.toUpperCase()}",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          faculty.position,
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColor.blackColor),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      color: AppColor.primaryColor,
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 7,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColor.primaryColor.withOpacity(0.1),
          highlightColor: AppColor.primaryColor.withOpacity(0.2),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColor.greyColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15.h,
                        width: 150.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        height: 12.h,
                        width: 100.w,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
