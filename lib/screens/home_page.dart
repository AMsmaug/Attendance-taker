import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/widgets/picking_class.dart';
import 'package:second_project/widgets/add_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentPage = "addClass";

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: -25,
            title: const Text(
              "AttendEasy",
              style: TextStyle(color: mainColor),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 30),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      clearPreferences().then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: mainColor),
                    )),
              )
            ],
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Classes",
                ),
                Tab(
                  text: "Attendance",
                ),
              ],
              labelColor: mainColor,
              indicatorColor: mainColor,
            ),
          ),
          body: const TabBarView(
            children: [AddClass(), PickingClass()],
          )),
    );
  }
}
