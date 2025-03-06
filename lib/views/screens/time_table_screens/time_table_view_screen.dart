import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/Faculty/time_table_controller.dart';
import '../../../core/utils/colors.dart';

class StudentTimeTableScreen extends StatelessWidget {
  final TimetableController timetableController =
  Get.put(TimetableController());

  StudentTimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: AppColor.whiteColor),
        backgroundColor: AppColor.primaryColor,
        title: Text('Lectures', style: TextStyle(color: AppColor.whiteColor)),
      ),
      body: Obx(
        () => ListView.builder(
          shrinkWrap: true,
          itemCount: timetableController.timetables.length,
          itemBuilder: (context, index) {
            final timetable = timetableController.timetables[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListTile(
                trailing: Icon(Icons.add_alert_rounded,size: 30.sp,color: AppColor.primaryColor,),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                title: Text(
                  timetable.subject,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    Text(
                      '${timetable.day} at ${timetable.time}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      'Prof.${timetable.instructor}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
