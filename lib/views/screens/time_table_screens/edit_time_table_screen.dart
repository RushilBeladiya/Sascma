import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/Faculty/time_table_controller.dart';
import '../../../core/utils/colors.dart';
import '../../../models/time_table_model.dart';

class EditTimetableView extends StatefulWidget {
  final Timetable timetable;

  const EditTimetableView({super.key, required this.timetable});

  @override
  State<EditTimetableView> createState() => _EditTimetableViewState();
}

class _EditTimetableViewState extends State<EditTimetableView> {
  final TimetableController timetableController = Get.find();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    subjectController.text = widget.timetable.subject;
    dayController.text = widget.timetable.day;
    timeController.text = widget.timetable.time;
    instructorController.text = widget.timetable.instructor;

    // Parse day for pre-selection
    List<String> dayParts = widget.timetable.day.split('/');
    if (dayParts.length == 3) {
      selectedDate = DateTime(int.parse(dayParts[2]), int.parse(dayParts[1]),
          int.parse(dayParts[0]));
    }

    // Parse time for pre-selection, handling 'am' and 'pm'
    String time = widget.timetable.time.toLowerCase();
    bool isPM = time.contains("pm");

    // Remove 'am' or 'pm' and split the time
    time = time.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
    List<String> timeParts = time.split(':');

    if (timeParts.length == 2) {
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      selectedTime = TimeOfDay(
        hour: hour,
        minute: minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColor.whiteColor,
        ),
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        title: Text(
          'Edit Lectures',
          style: TextStyle(color: AppColor.whiteColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(subjectController, 'Subject'),
              SizedBox(height: 20.h),
              _buildDatePicker(context),
              SizedBox(height: 20.h),
              _buildTimePicker(context),
              SizedBox(height: 20.h),
              _buildTextField(instructorController, 'Instructor'),
              SizedBox(height: 20.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (selectedDate != null && selectedTime != null) {
                      String day =
                          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
                      String time =
                          "${selectedTime!.hour}:${selectedTime!.minute} ${selectedTime!.period.name}";

                      var updatedTimetable = Timetable(
                        id: widget.timetable.id,
                        subject: subjectController.text,
                        day: day,
                        time: time,
                        instructor: instructorController.text,
                      );
                      timetableController.updateTimetable(updatedTimetable);
                      Get.back();
                    } else {
                      Get.snackbar(
                          "Error", "Please select both date and time.");
                    }
                  }
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: AppColor.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
            dayController.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: dayController,
          decoration: InputDecoration(
            labelText: 'Select Date',
            hintText: 'Tap to select a date',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null && pickedTime != selectedTime) {
          setState(() {
            selectedTime = pickedTime;
            timeController.text =
                "${pickedTime.hour}:${pickedTime.minute} ${pickedTime.period.name}";
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: timeController,
          decoration: const InputDecoration(
            labelText: 'Select Time',
            hintText: 'Tap to select a time',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
