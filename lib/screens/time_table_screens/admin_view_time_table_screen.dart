import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/core/utils/colors.dart';

import '../../../controller/Faculty/time_table_controller.dart';
import 'add_time_table_screen.dart';
import 'edit_time_table_screen.dart';

class AdminTimeTableScreen extends StatefulWidget {
  const AdminTimeTableScreen({Key? key}) : super(key: key);

  @override
  State<AdminTimeTableScreen> createState() => _AdminTimeTableScreenState();
}

class _AdminTimeTableScreenState extends State<AdminTimeTableScreen> {
  final TimetableController timetableController =
      Get.put(TimetableController());

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
                      'prof.${timetable.instructor}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColor.primaryColor),
                      onPressed: () async {
                        await Get.to(
                            () => EditTimetableView(timetable: timetable));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        timetableController.removeTimetable(timetable.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 20.w, bottom: 20.h),
        child: FloatingActionButton(
          backgroundColor: AppColor.primaryColor,
          onPressed: () async {
            await Get.to(() => const AddTimetableView());
          },
          child: Icon(Icons.add, color: AppColor.whiteColor, size: 25.sp),
        ),
      ),
    );
  }
}
