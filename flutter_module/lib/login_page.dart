import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_module/card.dart';
import 'package:flutter_module/splash_screen.dart';
import 'package:flutter_module/sss.dart';


import 'package:http/http.dart' as https;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late SharedPreferences sharedPreferences;

  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  var jsonData = null;

  Future signIn() async {
    Map data = {
      "user_name": user.text.toString(),
      "password": pass.text.toString(),
    };
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response;

    if (user.text.isNotEmpty) {
      response = await https.post(
          Uri.parse("http://103.101.197.249:8080/tollapi/api/login"),
          body: data);
      jsonData = json.decode(response.body);
      setState(() {
        sharedPreferences.setString("username", jsonData['data']['user_name']);
        sharedPreferences.setString("password", jsonData['data']['password']);
      });

      if (response.statusCode == 200) {
        setState(() {
          sharedPreferences.setString(
              "headers", response.headers['set-cookie']);
        });
        print(response.headers["set-cookie"]);
        Fluttertoast.showToast(
          msg: "Login Successful",
          gravity: ToastGravity.CENTER_LEFT,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 20,
        );
        print(response.statusCode);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => SplashScreenPage()));
      }
    } else {
      print(response.statusCode);
      Fluttertoast.showToast(
        msg: "Login Not Successful",
        gravity: ToastGravity.CENTER_LEFT,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 20,
      );
    }
  }

  bool value = false;
  bool playAreas = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50, left: 10),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (BuildContext context, double _value, child) {
                        return Opacity(
                          opacity: _value,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: _value * 10),
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        "Regnum ETC Toll",
                        style: TextStyle(
                            fontSize: 60,
                            color: Colors.white,
                            fontFamily: "Raleway"),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 2,
                child: playAreas == false
                    ? TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (BuildContext context, double _value, child) {
                          return Opacity(
                            opacity: _value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(2, 2),
                                blurRadius: 50,
                                color: Colors.black.withOpacity(0.01),
                              ),
                            ],
                          ),
                          // ******************************Login*******************************
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 15, top: 20),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 310,
                                    child: TextField(
                                      controller: user,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        labelText: "User",
                                        hintText: "Username",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                        labelStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        prefixIcon: const Icon(
                                          Icons.perm_identity_sharp,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        floatingLabelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.deepPurpleAccent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                               SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 50,
                                width: 310,
                                child: TextField(
                                  controller: pass,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                    hintText: "Password",
                                    labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    prefixIcon: const Icon(
                                      Icons.vpn_key_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    floatingLabelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: MaterialButton(
                                  onPressed: () {
                                    signIn();
                                    // Navigator.push(
                                    //     context, MaterialPageRoute(builder: (_) => CardDesign()));
                                  },
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.white30,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // *************************************************************************
                    // ******************************Signup*************************************
                    // *************************************************************************
                    : TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInQuart,
                        builder: (BuildContext context, double _value, child) {
                          return Opacity(
                            opacity: _value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(2, 2),
                                blurRadius: 50,
                                color: Colors.black.withOpacity(0.01),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 20),
                                    child: Text(
                                      "Signup",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 310,
                                    child: TextField(
                                      readOnly: true,
                                      showCursor: true,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        hintText: "Username or E-mail",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                        labelStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        prefixIcon: const Icon(
                                          Icons.perm_identity_sharp,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        floatingLabelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurpleAccent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: 310,
                                child: TextField(
                                  readOnly: true,
                                  showCursor: true,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                    hintText: "12345",
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    prefixIcon: const Icon(
                                      Icons.vpn_key_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    floatingLabelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: 310,
                                child: TextField(
                                  readOnly: true,
                                  showCursor: true,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    labelText: "Re-Enter Password",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                    hintText: "12345",
                                    labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    prefixIcon: const Icon(
                                      Icons.refresh,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    floatingLabelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      if (playAreas == true) {
                                        playAreas = false;
                                      }
                                    });
                                  },
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.deepPurpleAccent,
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                width: 270,
                                height: 45,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (playAreas == true) {
                                        playAreas = false;
                                      }
                                    });
                                  },
                                  child: Text(
                                    "Back to Login",
                                    style: TextStyle(
                                        color: Colors.deepPurple[900],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
