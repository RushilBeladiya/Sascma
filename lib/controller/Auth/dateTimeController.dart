import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateTimeController extends GetxController {
  var formattedTime = ''.obs;
  var formattedDate = ''.obs;

  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
  }

  void updateTime() {
    final now = DateTime.now();
    formattedTime.value = DateFormat('hh:mm:ss a').format(now); // Time format
    formattedDate.value = DateFormat('EEE, MMM d, yyyy').format(now); // Date format
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}
