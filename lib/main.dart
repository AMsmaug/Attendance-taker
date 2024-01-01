import 'package:flutter/material.dart';
import 'package:second_project/screens/class_attendance.dart';
import 'package:second_project/screens/class_info.dart';
import 'package:second_project/screens/home_page.dart';
import 'package:second_project/screens/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AttendEasy",
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(),
        "/home": (context) => const HomePage(),
        "/classInfo": (context) => const ClassInfo(),
        "/addAttendance": (context) => const AddAttendance(),
      },
    );
  }
}
