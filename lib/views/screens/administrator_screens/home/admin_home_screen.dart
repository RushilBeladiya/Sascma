
import 'package:flutter/material.dart';import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../controller/Administrator/home/admin_home_controller.dart';
import '../../../../controller/Auth/auth_controller.dart';
import '../../../../controller/Auth/dateTimeController.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/images.dart';
import '../../auth_screen/admin_auth_screen/faculty_registration_screen.dart';
import '../../student_screens/home/bottom_navigation_screen/profile_screen.dart';
import '../../student_screens/home/college_info_screen.dart';
import '../../student_screens/home/contact_us_screen.dart';
import '../../student_screens/setting_screen/settings_screen.dart';
import '../../student_screens/setting_screen/webview_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final DateTimeController dateTimeController = Get.find();
  final AuthController authController = Get.find();
  final AdminHomeController adminHomeController =
      Get.put(AdminHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.r),
              ),
            ),
            padding: EdgeInsets.only(
              right: 15.w,
              left: 15.w,
              bottom: 20.h,
              top: 40.h,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: AppColor.whiteColor,
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            dateTimeController.formattedDate.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            dateTimeController.formattedTime.value,
                            // Time
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.person_pin,
                        color: AppColor.whiteColor,
                        size: 22.sp,
                      ),
                      onPressed: () async {
                        await Get.to(() => const ProfileScreen());
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: AppColor.whiteColor,
                        size: 22.sp,
                      ),
                      onPressed: () async {
                        await Get.to(() => const SettingsScreen());
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  width: 400.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Obx(
                          () => CircleAvatar(
                            backgroundColor: AppColor.whiteColor,
                            radius: 42.r,
                            child: CircleAvatar(
                              radius: 40.r,
                              backgroundImage: adminHomeController.adminModel
                                      .value.profileImageUrl.isNotEmpty
                                  ? NetworkImage(adminHomeController
                                      .adminModel.value.profileImageUrl)
                                  : const AssetImage(AppImage.user)
                                      as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                "${adminHomeController.adminModel.value.firstName} ${adminHomeController.adminModel.value.lastName} ${adminHomeController.adminModel.value.surName}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.whiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Obx(
                              () => Text(
                                'Mobile : ${adminHomeController.adminModel.value.phoneNumber}',
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Obx(
                              () => Text(
                                'Email : ${adminHomeController.adminModel.value.email}',
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 20.h,
              ),
              crossAxisCount: 2,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1.8,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Get.to(() => const ProfileScreen());
                  },
                  child: buildDashboardItem(
                    title: "Student Info",
                    image: AppImage.studentInfo,
                  ),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: buildDashboardItem(
                //     title: "Attendance",
                //     image: AppImage.attandence,
                //   ),
                // ),
                // // GestureDetector(
                // //
                // //   child: buildDashboardItem(
                // //     title: "Time-Table",
                // //     image: AppImage.timetable,
                // //   ),
                // // ),
                // GestureDetector(
                //   onTap: () async {
                //     await Get.to(() => PdfListScreen());
                //   },
                //   child: buildDashboardItem(
                //     title: "Subjects",
                //     image: AppImage.subjects,
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () async {
                //     homeController.checkAdminCredentials()
                //         ? await Get.to(() => const AdminTimeTableScreen())
                //         : await Get.to(() => StudentTimeTableScreen());
                //   },
                //   child: buildDashboardItem(
                //     title: "Lectures",
                //     image: AppImage.lectures,
                //   ),
                // ),
                // buildDashboardItem(
                //   title: "Report",
                //   image: AppImage.report,
                // ),
                // buildDashboardItem(
                //   title: "Result",
                //   image: AppImage.result,
                // ),
                buildDashboardItem(
                  title: "Notice",
                  image: AppImage.notice,
                ),
                buildDashboardItem(
                  title: "Staff Profile",
                  image: AppImage.staffProfile,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CollegeInfoScreen());
                  },
                  child: buildDashboardItem(
                    title: "College Info",
                    image: AppImage.collegeInfo,
                  ),
                ),
                buildDashboardItem(
                  title: "Event",
                  image: AppImage.event,
                ),
                buildDashboardItem(
                  title: "Gallery",
                  image: AppImage.gallery,
                ),
                buildDashboardItem(
                  title: "Sports",
                  image: AppImage.sports,
                ),
                buildDashboardItem(
                  title: "Fee payment",
                  image: AppImage.feePayment,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => ContactUsScreen());
                  },
                  child: buildDashboardItem(
                    title: "Contact Us",
                    image: AppImage.contactus,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColor.appBackGroundColor,
        clipBehavior: Clip.antiAlias,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(
              () => UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(""),
                accountEmail: Text(""),
                currentAccountPicture: CircleAvatar(
                  radius: 32.r,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 32.r,
                    backgroundColor: AppColor.whiteColor,
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundImage: adminHomeController
                              .adminModel.value.profileImageUrl.isNotEmpty
                          ? NetworkImage(adminHomeController
                              .adminModel.value.profileImageUrl)
                          : const AssetImage(AppImage.user) as ImageProvider,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Add Faculty'),
              onTap: () async {
                await Get.to(() =>  FacultyRegistrationScreen()); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () async {
                await Get.to(() => const ProfileScreen()); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.share_rounded),
              title: Text('Share'),
              onTap: () {
                Share.share("Share CollegeApp");
              },
            ),
            ListTile(
              leading: Icon(Icons.star_half_rounded),
              title: Text('Rate us'),
              onTap: () {
                Get.to(() => const WebViewScreen(
                    url: "https://play.google.com", title: "RateUs App"));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await authController.logoutUser();
              },
            ),
            SizedBox(
              height: 265.h,
            ),
            Container(
              color: AppColor.primaryColor.withOpacity(0.2),
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () async {
                  await Get.to(
                      () => const SettingsScreen()); // Close the drawer
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardItem({required String title, required String image}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 15.w, right: 25.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            height: 28.h,
            fit: BoxFit.contain,
            image,
            filterQuality: FilterQuality.high,
          ),
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
