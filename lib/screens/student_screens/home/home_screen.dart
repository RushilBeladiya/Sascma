import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';

import '../../../../core/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StudentHomeController homeController = Get.put(StudentHomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        bottomNavigationBar: BottomAppBar(
          height: 65.h,
          color: AppColor.primaryColor,
          shape: CircularNotchedRectangle(),
          elevation: 10,
          notchMargin: 10,
          clipBehavior: Clip.antiAlias,
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColor.primaryColor,
            unselectedItemColor: AppColor.whiteColor,
            iconSize: 22.sp,
            showUnselectedLabels: true,
            selectedFontSize: 10.sp,
            unselectedFontSize: 10.sp,
            currentIndex: homeController.bottomScreenIndex.value,
            selectedItemColor: Colors.yellow,
            onTap: (index) {
              homeController.bottomScreenIndex.value = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: "Profile",
                activeIcon: Icon(
                  Icons.person,
                  color: Colors.yellow,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.verified_user_rounded,
                ),
                label: "Attendance",
                activeIcon: Icon(
                  Icons.verified_user_rounded,
                  color: Colors.yellow,
                ),
              ),
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment_rounded),
                label: "Fee Payment",
                activeIcon: Icon(
                  Icons.payment_rounded,
                  color: Colors.yellow,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Setting",
                activeIcon: Icon(
                  Icons.settings,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: 50.h,
          width: 50.h,
          child: FloatingActionButton(
            backgroundColor: AppColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            mini: false,
            // hoverElevation: 5,
            splashColor: Colors.grey,
            elevation: 3,
            child: Icon(
              Icons.home_rounded,
              color: AppColor.whiteColor,
            ),
            onPressed: () {
              homeController.bottomScreenIndex.value = 2;
            },
          ),
        ),
        body: homeController
            .bottomScreenList[homeController.bottomScreenIndex.value],
      ),
    );
  }
}
