import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Auth/auth_controller.dart';
import 'package:sascma/core/utils/colors.dart';

import '../../../../core/utils/images.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final logGlobalFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              AppImage.appLogo,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
              height: 90.h,
            ),
            const Spacer(),
            Form(
              key: logGlobalFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      hintStyle:
                          TextStyle(fontSize: 13.sp, color: AppColor.greyColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColor.primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
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
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      String phoneNumber = value!.trim();

                      if (phoneNumber.isEmpty) {
                        return ("Please enter your phone number.");
                      }

                      if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
                        return ("Please enter a valid phone number.");
                      }

                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      hintText: "Mobile Number",
                      hintStyle:
                          TextStyle(fontSize: 13.sp, color: AppColor.greyColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColor.primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  InkWell(
                    onTap: () async {
                      if (logGlobalFormKey.currentState!.validate()) {
                        AuthController.instance.loginAdminAndFaculty(
                          emailController.text.trim(),
                          phoneController.text.trim(),
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
                ],
              ),
            ),
            Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you an student? ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.blackColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    "Login Here",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
