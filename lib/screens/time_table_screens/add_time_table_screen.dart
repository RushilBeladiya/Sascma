import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/core/utils/colors.dart';

import '../../../controller/Faculty/time_table_controller.dart';
import '../../../models/time_table_model.dart';

class AddTimetableView extends StatefulWidget {
  const AddTimetableView({super.key});

  @override
  State<AddTimetableView> createState() => _AddTimetableViewState();
}

class _AddTimetableViewState extends State<AddTimetableView> {
  final TimetableController timetableController = Get.find();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
          centerTitle: true,
          leading: BackButton(
            color: AppColor.whiteColor,
          ),
          backgroundColor: AppColor.primaryColor,
          title: Text(
            'Add Lectures',
            style: TextStyle(color: AppColor.whiteColor),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(subjectController, 'Lecture Subject'),
              SizedBox(height: 20.h),

              _buildDatePicker(context), // Date Picker
              SizedBox(height: 20.h),

              _buildTimePicker(context), // Time Picker
              SizedBox(height: 20.h),

              _buildTextField(instructorController, 'Professor'),
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

                      var timetable = Timetable(
                        id: '',
                        subject: subjectController.text,
                        day: day,
                        time: time,
                        instructor: instructorController.text,
                      );
                      timetableController.addTimetable(timetable);
                      Get.back();
                    } else {
                      Get.snackbar(
                          "Error", "Please select both date and time.");
                    }
                  }
                },
                child: Text(
                  'Save',
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  // Date Picker Widget
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
            labelText: 'Lecture Date',
            hintText: 'Tap to select a date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }

  // Time Picker Widget
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
            timeController.text = "${pickedTime.hour}:${pickedTime.minute}";
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: timeController,
          decoration: InputDecoration(
            labelText: 'Lecture Time',
            hintText: 'Tap to select a time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }
}
