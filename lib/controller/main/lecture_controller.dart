import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LectureController extends GetxController {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("lectures");

  var selectedStream = RxnString();
  var selectedSubject = RxnString();
  var selectedSemester = Rxn<String>();

  var selectedDate = Rxn<DateTime>();
  var startTime = Rxn<TimeOfDay>();
  var endTime = Rxn<TimeOfDay>();
  var selectedDivision = RxnString();


  TextEditingController roomController = TextEditingController();

  List<String> semesters = [
    "Semester 1", "Semester 2", "Semester 3", "Semester 4",
    "Semester 5", "Semester 6", "Semester 7", "Semester 8"
  ];

  Map<String, Map<String, List<String>>> streamSemesterSubjects = {
    "B.COM": {
      "Semester 1": ["a", "b"], "Semester 2": ["c", "d"],
      "Semester 3": ["e", "f"], "Semester 4": ["g", "h"],
      "Semester 5": ["i", "j"], "Semester 6": ["k", "l"],
      "Semester 7": ["m", "n"], "Semester 8": ["o", "p"],
    },
    "BCA": {
      "Semester 1": ["a", "b"], "Semester 2": ["c", "d"],
      "Semester 3": ["e", "f"], "Semester 4": ["g", "h"],
      "Semester 5": ["i", "j"], "Semester 6": ["k", "l"],
      "Semester 7": ["m", "n"], "Semester 8": ["o", "p"],
    },
    "BBA": {
      "Semester 1": ["a", "b"], "Semester 2": ["c", "d"],
      "Semester 3": ["e", "f"], "Semester 4": ["g", "h"],
      "Semester 5": ["i", "j"], "Semester 6": ["k", "l"],
      "Semester 7": ["m", "n"], "Semester 8": ["o", "p"],
    },
  };

  List<String> getDivisions() {
    if (selectedSemester.value != null) {
      return ["A", "B", "C","D","E","F","G","H"];
    }
    return [];
  }

  List<String> getSemesters() {
    return selectedStream.value != null
        ? streamSemesterSubjects[selectedStream.value!]!.keys.toList()
        : [];
  }

  List<String> getSubjects() {
    if (selectedStream.value == null || selectedSemester.value == null) return [];
    return streamSemesterSubjects[selectedStream.value!]?[selectedSemester.value!] ?? [];
  }

  RxList<Map<String, dynamic>> studentLecturesList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> facultyLecturesList = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;


  void fetchStudentLectures(String stream, String semester) {
    isLoading.value = true;

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        DateTime now = DateTime.now();
        DateFormat dateFormat = DateFormat("dd-MM-yyyy"); // Format for parsing
        DateFormat time12Format = DateFormat("hh:mm a"); // 12-hour format with AM/PM
        DateFormat time24Format = DateFormat("HH:mm"); // 24-hour format

        studentLecturesList.value = data.entries
            .map((e) => {
          "id": e.key,
          ...Map<String, dynamic>.from(e.value),
        })
            .where((lecture) {
          final String lectureDateStr = lecture["date"]?.trim() ?? "";
          final String startTimeStr = lecture["start_time"]?.trim() ?? "";

          if (lectureDateStr.isEmpty || startTimeStr.isEmpty) return false;

          try {
            // Parse the lecture date (DD-MM-YYYY)
            DateTime lectureDate = dateFormat.parse(lectureDateStr);

            // Convert 12-hour time format (AM/PM) to 24-hour format
            DateTime lectureStartTime;
            if (startTimeStr.contains("AM") || startTimeStr.contains("PM")) {
              lectureStartTime = time12Format.parse(startTimeStr);
            } else {
              lectureStartTime = time24Format.parse(startTimeStr);
            }

            // Combine date and time
            DateTime fullLectureDateTime = DateTime(
              lectureDate.year,
              lectureDate.month,
              lectureDate.day,
              lectureStartTime.hour,
              lectureStartTime.minute,
            );

            // Show only today's and future lectures (excluding past ones)
            return (lectureDate.isAfter(now) ||
                (lectureDate.isAtSameMomentAs(now) &&
                    fullLectureDateTime.isAfter(now)));
          } catch (e) {
            print("Date parsing error: $e");
            return false;
          }
        })
            .toList();
      } else {
        studentLecturesList.clear();
      }

      isLoading.value = false;
    });
  }

  void fetchFacultyLectures(String stream, String semester, DateTime selectedDate) {
    isLoading.value = true;

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        DateFormat dateFormat = DateFormat("dd-MM-yyyy"); // Format for parsing

        facultyLecturesList.value = data.entries
            .map((e) => {
          "id": e.key,
          ...Map<String, dynamic>.from(e.value),
        })
            .where((lecture) {
          final String lectureStream = lecture["stream"] ?? "";
          final String lectureSemester = lecture["semester"] ?? "";
          final String lectureDateStr = lecture["date"]?.trim() ?? "";

          if (lectureStream.isEmpty || lectureSemester.isEmpty || lectureDateStr.isEmpty) return false;

          try {
            DateTime lectureDate = dateFormat.parse(lectureDateStr);

            return lectureStream == stream &&
                lectureSemester == semester &&
                lectureDate.day == selectedDate.day &&
                lectureDate.month == selectedDate.month &&
                lectureDate.year == selectedDate.year;
          } catch (e) {
            print("Date parsing error: $e");
            return false;
          }
        }).toList();

      } else {
        facultyLecturesList.clear();
      }

      isLoading.value = false;
    });
  }







  // void fetchLectures(String stream, String semester) {
  //   isLoading.value = true;
  //
  //   dbRef.onValue.listen((event) {
  //     final data = event.snapshot.value as Map<dynamic, dynamic>?;
  //
  //     if (data != null) {
  //       lecturesList.value = data.entries
  //           .map((e) => {
  //         "id": e.key,
  //         ...Map<String, dynamic>.from(e.value),
  //       })
  //           .where((lecture) =>
  //       lecture["stream"] == stream && lecture["semester"] == semester)
  //           .toList();
  //     } else {
  //       lecturesList.clear();
  //     }
  //
  //     isLoading.value = false;
  //   });
  // }
  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime firstDate = now; // Restricts to today and future dates

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }
  // Future<void> selectDate(BuildContext context) async {
  //   final DateTime now = DateTime.now();
  //   final DateTime lastSelectableDate = now.add(Duration(days: 7));
  //
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: now,
  //     firstDate: now,
  //     lastDate: lastSelectableDate,
  //   );
  //   if (picked != null) selectedDate.value = picked;
  // }
  Future<void> selectTime(BuildContext context, bool isStartTime) async {
    final now = DateTime.now();

    // Set the initial time
    TimeOfDay initialTime = isStartTime
        ? startTime.value ?? TimeOfDay.now()
        : endTime.value ?? TimeOfDay.now();

    // If today's date is selected, restrict to future times
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Prevent selecting past times for today
      if (selectedDate.value != null &&
          DateFormat('dd-MM-yyyy').format(selectedDate.value!) ==
              DateFormat('dd-MM-yyyy').format(now) &&
          selectedDateTime.isBefore(now)) {
        Get.snackbar("Invalid Time", "You cannot select a past time for today.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      if (isStartTime) {
        startTime.value = pickedTime;
      } else {
        endTime.value = pickedTime;
      }
    }
  }

  // Future<void> selectTime(BuildContext context, bool isStartTime) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (picked != null) {
  //     if (isStartTime) {
  //       startTime.value = picked;
  //     } else {
  //       endTime.value = picked;
  //     }
  //   }
  // }

  Future<void> addLecture(String profName, String userUid) async {
    if (selectedStream.value == null ||
        selectedSemester.value == null ||
        selectedDivision.value == null ||
        selectedSubject.value == null ||
        selectedDate.value == null ||
        startTime.value == null ||
        endTime.value == null ||
        roomController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill in all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      String key = dbRef.push().key!;

      String formattedStartTime = DateFormat('hh:mm a').format(
        DateTime(0, 0, 0, startTime.value!.hour, startTime.value!.minute),
      );

      String formattedEndTime = DateFormat('hh:mm a').format(
        DateTime(0, 0, 0, endTime.value!.hour, endTime.value!.minute),
      );

      await dbRef.child(key).set({
        'professor': profName,
        'uid': userUid,
        'stream': selectedStream.value,
        'semester': selectedSemester.value,
        'division': selectedDivision.value,
        'subject': selectedSubject.value,
        'date': DateFormat('dd-MM-yyyy').format(selectedDate.value!),
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        'room': roomController.text.trim(),
      });

      Get.snackbar("Success", "Lecture added successfully",
          backgroundColor: Colors.green, colorText: Colors.white);

      // Reset Fields
      selectedStream.value = null;
      selectedSemester.value = null;
      selectedDivision.value = null;
      selectedSubject.value = null;
      selectedDate.value = null;
      startTime.value = null;
      endTime.value = null;
      roomController.clear();

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to add lecture: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

}

// class LectureController extends GetxController {
//
//   final DatabaseReference dbRef = FirebaseDatabase.instance.ref("lectures");
//   var selectedStream = RxnString();
//   var selectedSubject = RxnString();
//   var selectedSemester = Rxn<String>();
//   List<String> semesters = ["Semester 1", "Semester 2", "Semester 3", "Semester 4", "Semester 5", "Semester 6", "Semester 7", "Semester 8"];
//   var selectedDate = Rxn<DateTime>();
//   var startTime = Rxn<TimeOfDay>();
//   var endTime = Rxn<TimeOfDay>();
//
//   TextEditingController roomController = TextEditingController();
//
//
//
//   Map<String, Map<String, List<String>>> streamSemesterSubjects = {
//     "B.COM": {
//       "Semester 1": ["a", "b"],
//       "Semester 2": ["c", "d"],
//       "Semester 3": ["e", "f"],
//       "Semester 4": ["g", "h"],
//       "Semester 5": ["i", "j"],
//       "Semester 6": ["k", "l"],
//       "Semester 7": ["m", "n"],
//       "Semester 8": ["o", "p"],
//     },
//     "BCA": {
//       "Semester 1": ["a", "b"],
//       "Semester 2": ["c", "d"],
//       "Semester 3": ["e", "f"],
//       "Semester 4": ["g", "h"],
//       "Semester 5": ["i", "j"],
//       "Semester 6": ["k", "l"],
//       "Semester 7": ["m", "n"],
//       "Semester 8": ["o", "p"],
//     },
//     "BBA": {
//       "Semester 1": ["a", "b"],
//       "Semester 2": ["c", "d"],
//       "Semester 3": ["e", "f"],
//       "Semester 4": ["g", "h"],
//       "Semester 5": ["i", "j"],
//       "Semester 6": ["k", "l"],
//       "Semester 7": ["m", "n"],
//       "Semester 8": ["o", "p"],
//     },
//   };
//
//
//
//   List<String> getSemesters() {
//     return selectedStream.value != null
//         ? streamSemesterSubjects[selectedStream.value!]!.keys.toList()
//         : [];
//   }
//
//   List<String> getSubjects() {
//     if (selectedStream.value == null || selectedSemester.value == null) {
//       return [];
//     }
//
//     var semesterMap = streamSemesterSubjects[selectedStream.value!];
//
//     if (semesterMap == null) {
//       return [];
//     }
//
//     return semesterMap[selectedSemester.value] ?? [];
//   }
//
//   RxList<Map<String, dynamic>> lecturesList = <Map<String, dynamic>>[].obs;
//
//   RxBool isLoading = true.obs;
//
//   void fetchLectures(String stream, String semester) {
//     isLoading.value = true; // Show shimmer effect
//
//     dbRef.onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//
//       if (data != null) {
//         lecturesList.value = data.entries
//             .map((e) => {
//           "id": e.key,
//           ...Map<String, dynamic>.from(e.value),
//         })
//             .where((lecture) =>
//         lecture["stream"] == stream && lecture["semester"] == semester)
//             .toList();
//       } else {
//         lecturesList.value = [];
//       }
//
//       isLoading.value = false; // Hide shimmer effect
//     });
//   }
//
//
//
//   Future<void> selectDate(BuildContext context) async {
//     final DateTime now = DateTime.now();
//     final DateTime lastSelectableDate = now.add(Duration(days: 7));
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: now,
//       lastDate: lastSelectableDate,
//     );
//     if (picked != null) selectedDate.value = picked;
//   }
//
//   Future<void> selectTime(BuildContext context, bool isStartTime) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       if (isStartTime) {
//         startTime.value = picked;
//       } else {
//         endTime.value = picked;
//       }
//     }
//   }
//   Future<void> addLecture(String profName, String userUid) async {
//
//
//     if (selectedStream.value == null) {
//       Get.snackbar("Error", "Please select a Stream",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (selectedSemester.value == null) {
//       Get.snackbar("Error", "Please select a Semester",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (selectedSubject.value == null) {
//       Get.snackbar("Error", "Please select a Subject",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (selectedDate.value == null) {
//       Get.snackbar("Error", "Please select a Date",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (startTime.value == null) {
//       Get.snackbar("Error", "Please select a Start Time",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (endTime.value == null) {
//       Get.snackbar("Error", "Please select an End Time",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (roomController.text.trim().isEmpty) {
//       Get.snackbar("Error", "Please enter Room Number",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//
//     try {
//       String key = dbRef.push().key!; // Generate unique key
//       await dbRef.child(key).set({
//         'professor': profName,
//         'uid': userUid, // **Store Current User UID**
//         'stream': selectedStream.value,
//         'semester': selectedSemester.value,
//         'subject': selectedSubject.value,
//         'date': DateFormat('dd-MM-yyyy').format(selectedDate.value!),
//         'start_time': "${startTime.value!.hour}:${startTime.value!.minute.toString().padLeft(2, '0')}",
//         'end_time': "${endTime.value!.hour}:${endTime.value!.minute.toString().padLeft(2, '0')}",
//         'room': roomController.text.trim(),
//       });
//
//       Get.snackbar("Success", "Lecture added successfully",
//           backgroundColor: Colors.green, colorText: Colors.white);
//
//       // Reset Fields
//       selectedStream.value = null;
//       selectedSemester.value = null;
//       selectedSubject.value = null;
//       selectedDate.value = null;
//       startTime.value = null;
//       endTime.value = null;
//       roomController.clear();
//
//       Get.back();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to add lecture: ${e.toString()}",
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }
//
//
//
//
//
//
//
// }
