import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:second_project/constants/colors.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String authMessage = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "username"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your name!";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
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
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: "password"),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a password!";
                  } else {
                    String passwordLengthRegexString = r'^.{6,}$';
                    RegExp passwordLengthRegex =
                        RegExp(passwordLengthRegexString);

                    if (!passwordLengthRegex.hasMatch(value)) {
                      return 'A password length must be longer than 6 characters!';
                    } else {
                      String passwordValidationRegexString =
                          r'^(?=.*[A-Z])(?=.*\d).*$';
                      RegExp passwordValidationRegex =
                          RegExp(passwordValidationRegexString);

                      if (!passwordValidationRegex.hasMatch(value)) {
                        return "A password must contain at least one capital letter and number!";
                      }
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(hintText: "confirm password"),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter the password again!";
                  } else {
                    if (value != _passwordController.text) {
                      return "The two passwords are not the same!";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(mainColor)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // everything is ok
                      addAccount(context);
                    }
                  },
                  child: const Text("Sign up")),
              const SizedBox(
                height: 24,
              ),
              Text(
                authMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              )
            ],
          )),
    );
  }

  Future addAccount(BuildContext context) async {
    try {
      String url =
          "https://attendeasy.000webhostapp.com/authentication/add_account.php";
      var res = await http.post(Uri.parse(url),
          body: jsonEncode({
            "name": _nameController.text,
            "email": _emailController.text,
            "password": _passwordController.text
          }));
      if (res.statusCode == 200) {
        print(res.body);
        var serverResponse = jsonDecode(res.body);
        print("done");
        print(serverResponse);
        if (serverResponse['code'] == 200) {
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            authMessage = "";
          });
          Navigator.pushNamed(context, "/home",
              arguments: int.parse(serverResponse['message']));
        } else {
          setState(() {
            authMessage = serverResponse['message'];
          });
        }
      } else {
        print("Failed to send data. Status code: ${res.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
