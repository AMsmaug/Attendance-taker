import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/model/Grade.dart';

class AddAttendance extends StatefulWidget {
  const AddAttendance({super.key});

  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  final searchBarController = TextEditingController();

  List<Student> foundStudents = [];
  Grade grade = Grade(gradeId: 0, gradeName: "", gradeStudents: []);
  bool firstRender = true;

  void runFilter(String enteredStudent) {
    List<Student> result = [];
    if (enteredStudent.isEmpty) {
      result = grade.gradeStudents!;
    } else {
      result = grade.gradeStudents!
          .where((student) => student.studentName!
              .toLowerCase()
              .contains(enteredStudent.toLowerCase()))
          .toList();
    }
    setState(() {
      foundStudents = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Grade gradeData = ModalRoute.of(context)!.settings.arguments as Grade;
    if (firstRender) {
      setState(() {
        grade = gradeData;
        foundStudents = grade.gradeStudents!;
      });
      firstRender = false;
    }
    String gradeName = grade.gradeName;

    return Scaffold(
      appBar: AppBar(
        title: Text("$gradeName's students"),
        backgroundColor: mainColor,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: searchBarController,
            onChanged: (value) {
              runFilter(value);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: greyColor,
              hintText: "Search for a student",
              prefixIcon: const Icon(Icons.search),
              prefixIconColor: mainColor,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(50.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          children: [
            if (foundStudents.isEmpty)
              const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      "No student found!",
                      style: TextStyle(fontSize: 24),
                    ),
                  ))
            else
              for (Student student in foundStudents.reversed)
                ListTile(
                  title: Text(student.studentName!),
                  leading: student.didAttend
                      ? const Icon(
                          Icons.check_box,
                          color: mainColor,
                        )
                      : const Icon(
                          Icons.check_box_outline_blank,
                          color: mainColor,
                        ),
                  onTap: () {
                    setState(() {
                      student.didAttend = !student.didAttend;
                    });
                  },
                ),
          ],
        ),
        if (foundStudents.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  List<Student> newAttendance = [];
                  for (Student student in grade.gradeStudents!) {
                    if (foundStudents.contains(student)) {
                      newAttendance
                          .add(foundStudents[foundStudents.indexOf(student)]);
                    } else {
                      newAttendance.add(student);
                    }
                  }
                  addAttendance(newAttendance);
                  // make the specific request (add the attendance)
                  setState(() {
                    gradeData.gradeStudents = newAttendance;
                  });

                  showSnackBar(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "Add Attendance",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Future<void> addAttendance(List<Student> students) async {
    try {
      String url = "https://attendeasy.000webhostapp.com/add_attendance.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "students": students.map((student) => student.toMap()).toList(),
        }),
      );

      if (res.statusCode == 200) {
        // var responseData = jsonDecode(res.body);
        var responseData = res.body;
        print("Response Data: $responseData");
        print("Done");
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}

void showSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: const Text('Attendance has added successfully!'),
    duration: const Duration(seconds: 3), // Optional, set the duration
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Perform an action when the user taps the "Undo" button
        // For example, you can undo the action that triggered the Snackbar
      },
    ),
    behavior: SnackBarBehavior
        .floating, // This makes the Snackbar appear at the bottom-right corner
  );

  // Show the Snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
