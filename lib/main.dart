import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sascma/controller/Auth/auth_controller.dart';
import 'package:sascma/core/utils/colors.dart';
import 'package:sascma/core/utils/routes.dart';
import 'package:sascma/screens/auth_screen/student_auth_screen/student_login_screen.dart';
import 'package:sascma/screens/auth_screen/student_auth_screen/student_registration_screen.dart';
import 'package:sascma/screens/splash_screen/splash_screen.dart';
import 'package:sascma/screens/student_screens/home/home_screen.dart';

import 'controller/Auth/dateTimeController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(DateTimeController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          title: 'College Management',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: AppColor.primaryColor.withOpacity(0.5),
              selectionHandleColor: AppColor.primaryColor,
            ),
          ),
          home: child,
          initialRoute: Routes.splashPage,
          getPages: [
            GetPage(name: Routes.splashPage, page: () => SplashScreen()),
            GetPage(
                name: Routes.registrationPage,
                page: () => StudentRegistrationScreen()),
            GetPage(
                name: Routes.loginPage, page: () => const StudentLoginScreen()),
            GetPage(name: Routes.homePage, page: () => HomeScreen()),
          ],
        );
      },
      child: SplashScreen(),
    );
  }
}
