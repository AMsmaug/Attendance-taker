import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String authMessage = "";

  Future _setIdInSharedPreferences(int instId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("instId", instId);
    } catch (error) {
      print("Error: $error");
    }
  }

  // get instId from preferences
  Future<int> _getIdFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idFromPreferences = prefs.getInt("instId");
      if (idFromPreferences == null) {
        return 0;
      } else {
        print("inst id from getIdFromPreferences: $idFromPreferences");
        return idFromPreferences;
      }
    } catch (error) {
      print("Error: $error");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    _getIdFromSharedPreferences().then((value) {
      print("value from function call: $value");
      if (value != 0) {
        Navigator.pushNamed(context, "/home", arguments: value);
      }
    });
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(hintText: "email"),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your email!";
                      } else {
                        String emailRegex =
                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
                        RegExp emailRegExp = RegExp(emailRegex);

                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      }
                    }),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "password"),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a password!";
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(mainColor),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        checkCredentials(_emailController.text,
                            _passwordController.text, context);
                      }
                    },
                    child: const Text("Login")),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  authMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                )
              ])),
    );
  }

  Future checkCredentials(
      String email, String password, BuildContext context) async {
    try {
      String url =
          "https://attendeasy.000webhostapp.com/authentication/check_credentials.php";
      var res = await http.post(Uri.parse(url),
          body: jsonEncode({"email": email, "password": password}));
      if (res.statusCode == 200) {
        var serverResponse = jsonDecode(res.body);
        print(serverResponse);
        if (serverResponse['code'] == 401) {
          setState(() {
            authMessage = serverResponse['message'];
          });
        } else {
          // put the references
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            authMessage = "";
          });
          _setIdInSharedPreferences(int.parse(serverResponse['message']));
          Navigator.pushNamed(context, "/home",
              arguments: int.parse(serverResponse['message']));
        }
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print(error);
    }
  }
}
