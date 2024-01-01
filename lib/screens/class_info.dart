import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/model/Grade.dart';

class ClassInfo extends StatefulWidget {
  const ClassInfo({super.key});

  @override
  State<ClassInfo> createState() => _ClassInfoState();
}

String studentToDelete = "";

class _ClassInfoState extends State<ClassInfo> {
  final studentController = TextEditingController();
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

    Future<void> addStudentDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Add a new student',
              style: TextStyle(color: mainColor),
            ),
            content: SizedBox(
              width: 300.0,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: studentController,
                      decoration: const InputDecoration(
                          hintText: "Enter the new student name"),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    grade.gradeStudents!.add(Student(
                        studentId: grade.gradeStudents!.length + 1,
                        studentName: studentController.text,
                        gradeId: grade.gradeId));
                  });
                  addStudent(Student(
                      studentId: grade.gradeStudents!.length,
                      studentName: studentController.text,
                      gradeId: grade.gradeId));
                  studentController.clear();
                  // make the specific request (add a new student to the class)
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: mainColor),
                ),
              ),
            ],
          );
        },
      );
    }

    Future<void> deleteStudentDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Remove $studentToDelete?",
              style: const TextStyle(color: mainColor),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Are you sure you want to remove $studentToDelete from this class?'),
                ],
              ),
            ),
            actions: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(mainColor)),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteStudent(grade.gradeStudents![grade.gradeStudents!
                        .indexWhere((student) =>
                            student.studentName == studentToDelete)]);
                    setState(() {
                      grade.gradeStudents!.removeWhere(
                          (element) => element.studentName == studentToDelete);
                      foundStudents = grade.gradeStudents!;
                    });
                    searchBarController.clear();
                    // make the specific request (remove a student from the class)
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(mainColor)),
                  child: const Text(
                    'yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
            ],
          );
        },
      );
    }

    String gradeName = grade.gradeName;

    return Scaffold(
      appBar: AppBar(
        title: Text("$gradeName's students"),
        backgroundColor: mainColor,
      ),
      body: Column(children: [
        if (grade.gradeStudents!.isEmpty)
          Column(
            children: [
              const SizedBox(
                height: 630,
                child: Center(
                    child: Text(
                  "The class is empty!",
                  style: TextStyle(fontSize: 24),
                )),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    addStudentDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    "Add student",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
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
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              studentToDelete = student.studentName!;
                            });
                            deleteStudentDialog(context);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      addStudentDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      "Add student",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          )
      ]),
    );
  }

  Future<void> addStudent(Student newStudent) async {
    try {
      String url =
          "http://localhost/mobile_project/student_info/add_student.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "studentId": newStudent.studentId.toString(),
          "studentName": newStudent.studentName,
          "gradeId": newStudent.gradeId.toString(),
          "didAttend": newStudent.didAttend ? "1" : "0"
        }),
      );

      if (res.statusCode == 200) {
        // var responseData = res.body;
        // print("Response Data: $responseData");
        print("Done");
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> deleteStudent(Student studentToDelete) async {
    try {
      String url =
          "http://localhost/mobile_project/student_info/delete_student.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "studentId": studentToDelete.studentId.toString(),
        }),
      );

      if (res.statusCode == 200) {
        // var responseData = res.body;
        // print("Response Data: $responseData");
        print("Done");
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
