import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sascma/controller/main/lecture_controller.dart';
import 'package:sascma/screens/faculty_screens/lecture_add_screen.dart';
import 'package:shimmer/shimmer.dart';

class FacultyLectureListScreen extends StatefulWidget {
  const FacultyLectureListScreen({super.key});

  @override
  State<FacultyLectureListScreen> createState() =>
      _FacultyLectureListScreenState();
}

class _FacultyLectureListScreenState extends State<FacultyLectureListScreen> {
  final LectureController lectureController = Get.put(LectureController());

  final RxString selectedStream = "BCA".obs;
  final RxString selectedSemester = "Semester 1".obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final List<String> streams = ["BCA", "BCOM", "BBA"];

  @override
  void initState() {
    super.initState();
    fetchLectures();
  }

  void fetchLectures() {
    lectureController.fetchFacultyLectures(
      selectedStream.value,
      selectedSemester.value,
      selectedDate.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculty Lectures"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildWeekDateSelector(),
          Expanded(
            child: Obx(() {
              if (lectureController.isLoading.value) {
                return _buildShimmerLoading();
              }

              final filteredLectures =
                  lectureController.facultyLecturesList.where((lecture) {
                final String lectureDate = lecture["date"];
                final String formattedSelectedDate =
                    DateFormat('dd-MM-yyyy').format(selectedDate.value);
                return lectureDate == formattedSelectedDate;
              }).toList();

              if (filteredLectures.isEmpty) {
                return Center(
                  child: Text(
                    "No lectures available",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                );
              }

              return AnimationLimiter(
                child: ListView.builder(
                  itemCount: filteredLectures.length,
                  itemBuilder: (context, index) {
                    final lecture = filteredLectures[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildLectureCard(lecture),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: FloatingActionButton.extended(
          onPressed: () {
            print("Create button clicked!");
            Get.to(() => LectureAddScreen());
            // Add lecture action here
          },
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            "Lecture",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          // Button color
          elevation: 5,
          // Shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded edges
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => DropdownButton<String>(
                value: selectedStream.value,
                onChanged: (value) {
                  selectedStream.value = value!;
                  fetchLectures();
                },
                items: streams
                    .map((stream) => DropdownMenuItem(
                          value: stream,
                          child: Text(stream),
                        ))
                    .toList(),
              )),
          Obx(() => DropdownButton<String>(
                value: selectedSemester.value,
                onChanged: (value) {
                  selectedSemester.value = value!;
                  fetchLectures();
                },
                items: lectureController.semesters
                    .map((semester) => DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildWeekDateSelector() {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          DateTime date = startOfWeek.add(Duration(days: index));
          return Obx(() {
            bool isSelected = date.day == selectedDate.value.day;
            return GestureDetector(
              onTap: () {
                selectedDate.value = date;
                fetchLectures();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ListTile(
              title: Container(height: 16, color: Colors.white),
              subtitle: Container(height: 12, color: Colors.white),
              leading: CircleAvatar(backgroundColor: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLectureCard(Map<String, dynamic> lecture) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.book, color: Colors.white),
        ),
        title: Text(
          lecture["subject"],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "📌 Professor: ${lecture["professor"]}\n"
            "Stream: ${lecture["stream"]}\n"
            "Semester: ${lecture["semester"]}\n"
            "📅 Date: ${lecture["date"]}\n"
            "⏰ Time: ${lecture["start_time"]} - ${lecture["end_time"]}\n"
            "🏫 Room No: ${lecture["room"]}",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
