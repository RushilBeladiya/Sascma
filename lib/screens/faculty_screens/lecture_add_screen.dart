import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sascma/controller/Faculty/home/faculty_home_controller.dart';

import '../../../controller/main/lecture_controller.dart';

class LectureAddScreen extends StatefulWidget {
  LectureAddScreen({super.key});

  @override
  State<LectureAddScreen> createState() => _LectureAddScreenState();
}

class _LectureAddScreenState extends State<LectureAddScreen> {
  final LectureController lectureController = Get.put(LectureController());
  final FacultyHomeController facultyHomeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Lecture"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              lectureController.addLecture(
                "${facultyHomeController.facultyModel.value.firstName} ${facultyHomeController.facultyModel.value.surName}",
                facultyHomeController.facultyModel.value.uid,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **Professor Name**
              Text("Professor Name",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(
                () => TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        "${facultyHomeController.facultyModel.value.firstName} ${facultyHomeController.facultyModel.value.surName}",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 16),

              /// **Stream Selection**
              Text("Stream", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                    value: lectureController.selectedStream.value,
                    items: lectureController.streamSemesterSubjects.keys
                        .map((stream) {
                      return DropdownMenuItem(
                        value: stream,
                        child: Text(stream),
                      );
                    }).toList(),
                    onChanged: (value) {
                      lectureController.selectedStream.value = value;
                      lectureController.selectedSemester.value =
                          null; // Reset Semester
                      lectureController.selectedDivision.value =
                          null; // Reset Division
                      lectureController.selectedSubject.value =
                          null; // Reset Subject
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )),
              SizedBox(height: 16),

              /// **Semester Selection**
              Text("Semester", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                    value: lectureController.selectedSemester.value,
                    items: lectureController.selectedStream.value != null
                        ? lectureController
                            .streamSemesterSubjects[
                                lectureController.selectedStream.value]!
                            .keys
                            .map((semester) => DropdownMenuItem(
                                  value: semester,
                                  child: Text(semester),
                                ))
                            .toList()
                        : [],
                    onChanged: (value) {
                      lectureController.selectedSemester.value = value;
                      lectureController.selectedDivision.value =
                          null; // Reset Division
                      lectureController.selectedSubject.value =
                          null; // Reset Subject
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )),
              SizedBox(height: 16),

              /// **Division Selection (Filtered by Semester)**
              Text("Division", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                    value: lectureController.selectedDivision.value,
                    items: lectureController.getDivisions().map((division) {
                      return DropdownMenuItem(
                        value: division,
                        child: Text(division),
                      );
                    }).toList(),
                    onChanged: (value) {
                      lectureController.selectedDivision.value = value;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )),
              SizedBox(height: 16),

              /// **Subject Selection (Filtered by Stream & Semester)**
              Text("Subject", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => DropdownButtonFormField<String>(
                    value: lectureController.selectedSubject.value,
                    items: lectureController.getSubjects().map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      lectureController.selectedSubject.value = value;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )),
              SizedBox(height: 16),

              /// **Lecture Start Time**
              Text("Lecture Start Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: lectureController.startTime.value == null
                          ? "Select Start Time"
                          : lectureController.startTime.value!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onTap: () => lectureController.selectTime(context, true),
                  )),
              SizedBox(height: 16),

              /// **Lecture End Time**
              Text("Lecture End Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: lectureController.endTime.value == null
                          ? "Select End Time"
                          : lectureController.endTime.value!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onTap: () => lectureController.selectTime(context, false),
                  )),
              SizedBox(height: 16),

              /// **Date Selection**
              Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: lectureController.selectedDate.value == null
                          ? "Select Date"
                          : DateFormat('dd-MM-yyyy')
                              .format(lectureController.selectedDate.value!),
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onTap: () => lectureController.selectDate(context),
                  )),
              SizedBox(height: 16),

              /// **Room Number**
              Text("Room No.", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: lectureController.roomController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Room Number",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
