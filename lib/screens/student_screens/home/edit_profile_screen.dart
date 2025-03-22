import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Student/home/student_home_controller.dart';
import 'package:sascma/core/utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  StudentHomeController homeController = Get.find();
  final editProfileGlobalFormKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // usernameController.text = homeController.userModel.value.firstName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      appBar: AppBar(
        title:
            Text('Edit Profile', style: TextStyle(color: AppColor.whiteColor)),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColor.whiteColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 25.w),
                child: Form(
                  key: editProfileGlobalFormKey,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              Obx(
                                () => CircleAvatar(
                                  radius: 50.r,
                                  //   backgroundImage: homeController
                                  //           .userModel
                                  //           .value
                                  //           .profileImageUrl
                                  //           .isNotEmpty
                                  //       ? NetworkImage(homeController
                                  //           .userModel
                                  //           .value
                                  //           .profileImageUrl)
                                  //       : const AssetImage(AppImage.user)
                                  //           as ImageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () async {
                                    // await homeController.uploadProfileImage(
                                    //     "homeController.userModel.value.uid");
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5.r),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      TextFormField(
                        autofocus: false,
                        cursorColor: AppColor.primaryColor,
                        controller: usernameController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Please Enter your username.");
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(value)) {
                            return ("Please Enter a valid username");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          usernameController.text = value!;
                        },
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          hintText: "Username",
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
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () async {
                          // if (editProfileGlobalFormKey.currentState!
                          //     .validate()) {
                          //   await homeController
                          //       .updateUserData(usernameController.text.trim());
                          //   Get.back();
                          // }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          margin: EdgeInsets.symmetric(horizontal: 40.w),
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
                              "Update",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
