import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controller/Auth/auth_controller.dart';
import '../../../../core/utils/colors.dart';

class FacultyRegistrationScreen extends StatefulWidget {
  const FacultyRegistrationScreen({super.key});

  @override
  State<FacultyRegistrationScreen> createState() => _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState extends State<FacultyRegistrationScreen> {
  final regGlobalFormKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedPosition;
  final List<String> positions = ["Professor", "Assistant", "HOD", "Tutor","Principal"];

  final textFieldFocusNode = FocusNode();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 60.h, bottom: 20.w, left: 20.h),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Registration Faculty",
                    style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Create Faculty account",
                    style:
                    TextStyle(color: AppColor.greyColor, fontSize: 15.sp),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
              child: Column(
                children: [
                  Form(
                    key: regGlobalFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: false,
                          maxLength: 15,
                          buildCounter: (_,
                              {required int currentLength,
                                required bool isFocused,
                                required int? maxLength}) {
                            return null;
                          },
                          cursorColor: AppColor.primaryColor,
                          controller: firstnameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            String firstName = value!.trim();

                            if (firstName.isEmpty) {
                              return ("Please enter your First name.");
                            }

                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(firstName)) {
                              return ("Please enter a valid First name.");
                            }

                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "First Name",
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
                        SizedBox(
                          height: 10.h,
                        ),
                        TextFormField(
                          autofocus: false,
                          maxLength: 15,
                          buildCounter: (_,
                              {required int currentLength,
                                required bool isFocused,
                                required int? maxLength}) {
                            return null;
                          },
                          cursorColor: AppColor.primaryColor,
                          controller: lastnameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            String lastName = value!.trim();

                            if (lastName.isEmpty) {
                              return ("Please enter your Last name.");
                            }

                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(lastName)) {
                              return ("Please enter a valid Last name.");
                            }

                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "Last Name",
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
                        SizedBox(
                          height: 10.h,
                        ),
                        TextFormField(
                          autofocus: false,
                          maxLength: 15,
                          buildCounter: (_,
                              {required int currentLength,
                                required bool isFocused,
                                required int? maxLength}) {
                            return null;
                          },
                          cursorColor: AppColor.primaryColor,
                          controller: surnameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            String surName = value!.trim();

                            if (surName.isEmpty) {
                              return ("Please enter your surname.");
                            }

                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(surName)) {
                              return ("Please enter a valid surname.");
                            }

                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "surname",
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
                        SizedBox(
                          height: 10.h,
                        ),
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
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_rounded),
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
                        SizedBox(
                          height: 10.h,
                        ),
                        SizedBox(height: 10.h),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.work),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "Select Position",
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
                          value: selectedPosition,
                          items: positions.map((String position) {
                            return DropdownMenuItem<String>(
                              value: position,
                              child: Text(position),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedPosition = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a position' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  GestureDetector(
                    onTap: () async {
                      if (regGlobalFormKey.currentState!.validate()) {
                        AuthController.instance.registerFaculty(
                          firstnameController.text.trim(),
                          lastnameController.text.trim(),
                          surnameController.text.trim(),
                          phoneController.text.trim(),
                          emailController.text.trim(),
                          selectedPosition!,
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
                          "Register",
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
          ],
        ),
      ),
    );
  }
}
