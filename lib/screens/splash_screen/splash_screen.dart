import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/core/utils/colors.dart';
import 'package:sascma/core/utils/images.dart';
import 'package:sascma/screens/auth_screen/student_auth_screen/student_login_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void navigationToLogin() async {
    Timer(const Duration(seconds: 3), () async {
      Get.offAll(() => StudentLoginScreen());
    });
  }

  @override
  void initState() {
    super.initState();
    navigationToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      body: Center(
        child: Image.asset(
          AppImage.appLogo,
          filterQuality: FilterQuality.high,
          fit: BoxFit.contain,
          height: 130.h,
        ),
      ),
    );
  }
}
