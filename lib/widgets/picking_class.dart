import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/model/Grade.dart';

class PickingClass extends StatefulWidget {
  const PickingClass({super.key});

  @override
  State<PickingClass> createState() => _PickingClassState();
}

class _PickingClassState extends State<PickingClass> {
  List<Grade> grades = [];
  bool firstRender = true;
  int instId = 0;

  String classAttendentStudents(Grade grade) {
    int cnt = 0;
    for (Student student in grade.gradeStudents!) {
      if (student.didAttend) cnt++;
    }
    return "$cnt";
  }

  @override
  Widget build(BuildContext context) {
    final int instIdAsNumber =
        ModalRoute.of(context)!.settings.arguments as int;
    setState(() {
      instId = instIdAsNumber;
    });
    if (firstRender) {
      getContent();
      firstRender = false;
    }
    if (grades.isEmpty) {
      return const Expanded(
        child: Center(
            child: Text(
          "No classes exist!",
          style: TextStyle(fontSize: 24),
        )),
      );
    } else {
      return ListView(children: [
        const SizedBox(
          height: 20,
        ),
        for (Grade grade in grades)
          ListTile(
            title: Text(grade.gradeName),
            trailing: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  classAttendentStudents(grade),
                  style: const TextStyle(color: Colors.white),
                )),
            onTap: () {
              Navigator.pushNamed(context, "/addAttendance", arguments: grade);
            },
          )
      ]);
    }
  }

  Future<void> getContent() async {
    try {
      String url =
          "https://attendeasy.000webhostapp.com/grade_info/get_grades.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "instId": instId.toString(),
        }),
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        print(responseData);
        List<Grade> content = [];
        for (int i = 0; i < responseData.length; i++) {
          content.add(Grade(
            gradeId: int.parse(responseData[i]["gradeId"]),
            gradeName: responseData[i]["gradeName"],
            gradeStudents: (responseData[i]["gradeStudents"] as List)
                .map((studentData) => Student(
                    studentId: int.parse(studentData["studentId"]),
                    studentName: studentData["studentName"],
                    gradeId: int.parse(studentData["gradeId"]),
                    didAttend: studentData['didAttend'] == '1'))
                .toList(),
          ));
        }
        setState(() {
          grades = content;
        });
        print("Done");
        print("Response Data: $responseData");
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
