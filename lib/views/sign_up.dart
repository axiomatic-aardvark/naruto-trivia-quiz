import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:quizapp/helpers/constants.dart';
import 'package:quizapp/helpers/functions.dart';
import 'package:quizapp/services/auth.dart';
import 'package:quizapp/views/sign_in.dart';
import 'package:quizapp/widgets/widgets.dart';

import 'home.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String name, email, password;
  AuthService authService = AuthService();

  bool _isLoading = false;
  final bool _isEmailAlreadyInUse = false;

  // TODO: Make this generic and export to 'utils' folder
  Future createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Icon(IconData(59137, fontFamily: 'MaterialIcons'),
                color: Colors.red),
            // ignore: avoid_escaping_inner_quotes
            content: Text("Email address \"$email\" is already in use."),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: const Text("CLOSE"),
              )
            ],
          );
        });
  }

  // ignore: type_annotate_public_apis, always_declare_return_types
  signUp() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .signUpWithEmailAndPassword(email, password)
          .then((value) {
        if (value != null) {
          setState(() {
            _isLoading = false;
          });
          if (value.toString().substring(0, 1) != "[") {
            HelperFunctions.saveLoggedUserDetails(isLoggedIn: true);

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            // TODO: Make this more generic and export to 'utils' folder
            final int lastSquareBracketIndex =
                value.toString().substring(1).indexOf("]");
            if (value.toString().substring(0, lastSquareBracketIndex + 2) ==
                "[firebase_auth/email-already-in-use]") {
              createAlertDialog(context);
            }
          }
        } else {
          // ignore: avoid_print
          print("Invalid request.");
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      // ignore: avoid_print
      print("Form values are invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: MAIN_COLOR,
          elevation: 0,
          brightness: Brightness.light),
      body: _isLoading
          // ignore: avoid_unnecessary_containers
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter name.";
                        }

                        if (value.length < 3) {
                          return "Name must be at least 3 characters long.";
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Name",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MAIN_COLOR, width: 2.0),
                        ),
                      ),
                      onChanged: (val) {
                        name = val;
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (_isEmailAlreadyInUse) {
                          return "Email address already in use.";
                        }

                        if (value.isEmpty) {
                          return "Please enter email address.";
                        }

                        // TODO: extract this in utils folder
                        final bool isValidEmail = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email);

                        if (!isValidEmail) {
                          return "Please enter a valid email address.";
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Email",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MAIN_COLOR, width: 2.0),
                        ),
                      ),
                      onChanged: (val) {
                        email = val;
                      },
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter password.";
                        }

                        if (value.length < 6) {
                          return "Password must be at least 6 characters long.";
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Password",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MAIN_COLOR, width: 2.0),
                        ),
                      ),
                      onChanged: (val) {
                        password = val;
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        signUp();
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              color: MAIN_COLOR,
                              borderRadius: BorderRadius.circular(30)),
                          height: 50,
                          width: MediaQuery.of(context).size.width - 48,
                          alignment: Alignment.center,
                          child: const Text("Sign Up",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16))),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()));
                          },
                          child: const Text("Click here.",
                              style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }
}