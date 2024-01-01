import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:second_project/widgets/login.dart';
import 'package:second_project/widgets/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: const TabBar(
              tabs: [
                Tab(
                  text: "Login",
                ),
                Tab(
                  text: "Sign up",
                ),
              ],
              labelColor: mainColor,
              indicatorColor: mainColor,
            ),
          ),
          body: const TabBarView(
            children: [Login(), SignUp()],
          )),
    );
  }
}
