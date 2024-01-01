import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/model/Grade.dart';

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  final _gradeController = TextEditingController();

  List<Grade> grades = [];

  String classToDelete = "";
  int instId = 0;

  Future<void> _addClassDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Create a new class',
            style: TextStyle(color: mainColor),
          ),
          content: SizedBox(
            width: 300.0,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                        hintText: "Enter the new class name"),
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
                  grades.add(Grade(
                      gradeId: grades.length + 1,
                      gradeName: _gradeController.text,
                      gradeStudents: []));
                  // here to make the specific request (create new class)
                  addGrade(Grade(
                      gradeId: grades.length,
                      gradeName: _gradeController.text,
                      gradeStudents: []));

                  _gradeController.clear();
                });
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

  Future<void> _deleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete $classToDelete?",
            style: const TextStyle(color: mainColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete $classToDelete?'),
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
                  deleteGrade(grades[grades.indexWhere(
                      (grade) => grade.gradeName == classToDelete)]);
                  setState(() {
                    grades.removeWhere(
                        (element) => element.gradeName == classToDelete);
                  });
                  // make the specific request (delete a class)
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

  bool firstRender = true;

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
    // print(grades[grades.length - 1].gradeId);
    if (grades.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: Center(
                child: Text(
              "No classes exist!",
              style: TextStyle(fontSize: 24),
            )),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 10),
              child: ElevatedButton(
                onPressed: () {
                  _addClassDialog(context);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(mainColor),
                    shape: MaterialStateProperty.all<CircleBorder>(
                        const CircleBorder())),
                child: const Text(
                  "+",
                  style: TextStyle(fontSize: 33),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              children: [
                for (Grade grade in grades)
                  ListTile(
                    title: Text(grade.gradeName),
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            classToDelete = grade.gradeName;
                          });
                          _deleteDialog(context);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                    onTap: () {
                      Navigator.pushNamed(context, "/classInfo",
                          arguments: grade);
                    },
                  )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 10),
              child: ElevatedButton(
                onPressed: () {
                  _addClassDialog(context);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(mainColor),
                    shape: MaterialStateProperty.all<CircleBorder>(
                        const CircleBorder())),
                child: const Text(
                  "+",
                  style: TextStyle(fontSize: 33),
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  Future<void> addGrade(Grade newGrade) async {
    try {
      String url =
          "https://attendeasy.000webhostapp.com/grade_info/add_grade.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "gradeId": newGrade.gradeId.toString(),
          "gradeName": newGrade.gradeName,
          "instId": instId.toString()
        }),
      );

      if (res.statusCode == 200) {
        print(res.body);
        var responseData = jsonDecode(res.body);
        if (responseData['code'] == 200) {
          setState(() {
            newGrade.gradeId = int.parse(responseData['message']);
          });
        }
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> deleteGrade(Grade gradeToDelete) async {
    try {
      String url =
          "https://attendeasy.000webhostapp.com/grade_info/delete_grade.php";
      var res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "gradeId": gradeToDelete.gradeId.toString(),
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
        print(res.body);
        var responseData = jsonDecode(res.body);
        print("response from getContent: $responseData");
        List<Grade> content = [];
        for (int i = 0; i < responseData.length; i++) {
          content.add(Grade(
            gradeId: int.parse(responseData[i]["gradeId"]),
            gradeName: responseData[i]["gradeName"],
            gradeStudents: (responseData[i]["gradeStudents"] as List)
                .map((studentData) => Student(
                    studentId: int.parse(studentData["studentId"]),
                    studentName: studentData["studentName"],
                    gradeId: int.parse(studentData["gradeId"])))
                .toList(),
          ));
        }
        setState(() {
          grades = content;
        });
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
