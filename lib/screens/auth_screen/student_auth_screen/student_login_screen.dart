import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Auth/auth_controller.dart';
import 'package:sascma/core/utils/colors.dart';

import '../../../../core/utils/images.dart';
import '../admin_auth_screen/admin_login_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final logGlobalFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController spidController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280.h,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
              ),
              child: Column(
                children: [
                  SizedBox(height: 80.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColor.whiteColor,
                            Colors.tealAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'STERS',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Image.asset(
                        AppImage.appLogo,
                        height: 100.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 220.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                  ),
                  SizedBox(height: 20.h),
                  Form(
                    key: logGlobalFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: false,
                          maxLength: 40,
                          buildCounter: (_,
                              {required int currentLength,
                              required bool isFocused,
                              required int? maxLength}) {
                            return null;
                          },
                          cursorColor: AppColor.primaryColor,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            String email = value!.trim();

                            if (email.isEmpty) {
                              return ("Please enter your email.");
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                                .hasMatch(email)) {
                              return ("Please enter a valid email.");
                            }

                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_rounded),
                            // suffixIcon: isEmailVerified
                            //     ? Icon(Icons.check_circle, color: Colors.green)
                            //     : ElevatedButton(
                            //   onPressed: isTimerRunning ? null : sendVerificationEmail,
                            //   child: Text(isTimerRunning ? "$remainingSeconds s" : "Verify"),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: AppColor.primaryColor,
                            //     foregroundColor: Colors.white,
                            //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                            //     textStyle: TextStyle(fontSize: 12.sp),
                            //   ),
                            // ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "email",
                            hintStyle: TextStyle(
                                fontSize: 13.sp, color: AppColor.greyColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColor.primaryColor, width: 1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        TextFormField(
                          autofocus: false,
                          maxLength: 10,
                          buildCounter: (_,
                              {required int currentLength,
                              required bool isFocused,
                              required int? maxLength}) {
                            return null;
                          },
                          cursorColor: AppColor.primaryColor,
                          controller: spidController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            String spid = value!.trim();

                            if (spid.isEmpty) {
                              return ("Please enter SPID.");
                            }

                            if (!RegExp(r'^\d{10}$').hasMatch(spid)) {
                              return ("Please enter a valid SPID");
                            }

                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.verified_user_rounded),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "SPID",
                            hintStyle: TextStyle(
                                fontSize: 13.sp, color: AppColor.greyColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColor.primaryColor, width: 1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  InkWell(
                    onTap: () async {
                      if (logGlobalFormKey.currentState!.validate()) {
                        AuthController.instance.loginStudent(
                          emailController.text.trim(),
                          spidController.text.trim(),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor,
                              blurRadius: 0.5,
                              spreadRadius: 0.2,
                            ),
                          ]),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.whiteColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you an administrator? ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.blackColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => AdminLoginScreen());
                  },
                  child: Text(
                    "Login Here",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
