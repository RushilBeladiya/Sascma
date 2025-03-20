import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/Auth/auth_controller.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/images.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final GlobalKey<FormState> logGlobalFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController spidController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  bool isEmailVerified = false;
  bool isLoading = false;
  bool isTimerRunning = false;
  int remainingSeconds = 90;

  Timer? timer;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// ✅ Check if user is already logged in
  void checkCurrentUser() {
    currentUser = auth.currentUser;
    if (currentUser != null) {
      checkEmailVerification();
    }
  }

  /// ✅ Check if email is verified
  Future<void> checkEmailVerification() async {
    if (currentUser != null) {
      await currentUser!.reload();
      setState(() => isEmailVerified = currentUser!.emailVerified);
    }
  }

  /// ✅ Timer logic with dynamic UI updates
  void startTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }

    setState(() {
      isTimerRunning = true;
      remainingSeconds = 90;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await checkEmailVerification();

      if (isEmailVerified) {
        timer.cancel();
        setState(() => isTimerRunning = false);
      } else if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => isTimerRunning = false);
      }
    });
  }

  /// ✅ Send verification email
  Future<void> sendVerificationEmail() async {
    setState(() => isLoading = true);

    String email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email.');
      setState(() => isLoading = false);
      return;
    }

    try {
      await AuthController.instance.sendVerificationEmail(email);
      startTimer();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification email: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Handle login button with verification check
  Future<void> handleLogin() async {
    if (!logGlobalFormKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String spid = spidController.text.trim();

    setState(() => isLoading = true);

    try {
      await AuthController.instance.loginStudent(email, spid);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Column(
          children: [
            const Spacer(),

            /// ✅ App Logo
            Image.asset(
              AppImage.appLogo,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
              height: 90,
            ),

            const Spacer(),

            /// ✅ Form Fields
            Form(
              key: logGlobalFormKey,
              child: Column(
                children: [
                  /// ✅ Email Field with Verification Button
                  TextFormField(
                    autofocus: false,
                    maxLength: 40,
                    cursorColor: AppColor.primaryColor,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded),
                      suffixIcon: isEmailVerified
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              onPressed: isTimerRunning || isLoading
                                  ? null
                                  : sendVerificationEmail,
                              icon: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.blue, strokeWidth: 2)
                                  : const Icon(Icons.verified,
                                      color: Colors.blue),
                            ),
                      hintText: "Enter email",
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// ✅ SPID Field
                  TextFormField(
                    autofocus: false,
                    maxLength: 10,
                    cursorColor: AppColor.primaryColor,
                    controller: spidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.verified_user_rounded),
                      hintText: "Enter SPID",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ Login Button
            InkWell(
              onTap: handleLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
