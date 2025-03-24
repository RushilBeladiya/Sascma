import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controller/Auth/auth_controller.dart';
import '../../../../core/utils/colors.dart';

class StudentRegistrationScreen extends StatefulWidget {
  StudentRegistrationScreen({super.key});

  @override
  _StudentRegistrationScreenState createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final regGlobalFormKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController spIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final textFieldFocusNode = FocusNode();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? selectedStream;
  String? selectedSemester;
  String? selectedDivision;

  List<String> streams = ['BCA', 'BBA', 'BCOM'];
  List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8'
  ];
  List<String> division = ['A', 'B', 'C', 'D'];

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
                    "Registration Student",
                    style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Create Student account",
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
                          controller: spIdController,
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
                          textInputAction: TextInputAction.next,
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
                        DropdownButtonFormField<String>(
                          value: selectedStream,
                          onChanged: (value) {
                            setState(() {
                              selectedStream = value!;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "Stream",
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
                          validator: (value) {
                            if (value == null) {
                              return "Please select a stream!!!";
                            }
                            return null;
                          },
                          items: streams.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedSemester,
                          onChanged: (value) {
                            setState(() {
                              selectedSemester = value!;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "Semester",
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
                          validator: (value) {
                            if (value == null) {
                              return "Please select a Semester!!!";
                            }
                            return null;
                          },
                          items: semesters.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedDivision,
                          onChanged: (value) {
                            setState(() {
                              selectedDivision = value!;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: "Division",
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
                          validator: (value) {
                            if (value == null) {
                              return "Please select a Division!!!";
                            }
                            return null;
                          },
                          items: division.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  GestureDetector(
                    onTap: () async {
                      if (regGlobalFormKey.currentState!.validate()) {
                        AuthController.instance.registerStudent(
                          firstnameController.text.trim(),
                          lastnameController.text.trim(),
                          surnameController.text.trim(),
                          spIdController.text.trim(),
                          phoneController.text.trim(),
                          emailController.text.trim(),
                          selectedStream!,
                          selectedSemester!,
                          selectedDivision!,
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
