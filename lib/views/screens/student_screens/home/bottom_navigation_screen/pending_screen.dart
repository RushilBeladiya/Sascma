import 'package:flutter/material.dart';

import '../../../../../core/utils/colors.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackGroundColor,
      body: Center(
        child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColor.primaryColor,
            ),
            child: Center(
              child: Text(
                "Pending",
                style: TextStyle(color: AppColor.whiteColor),
              ),
            )),
      ),
    );
  }
}
