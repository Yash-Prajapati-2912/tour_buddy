import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourbuddy/pages/home.dart';

import 'package:tourbuddy/pages/signup.dart';
import 'package:tourbuddy/services/database.dart';
import 'package:tourbuddy/services/shared_pref.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "", myname = "", myid = "", myimage = "";
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  userLogin() async {
    if (mailcontroller.text == "" || passwordcontroller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Please enter email and password",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          )));
      return;
    }

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
      await DatabaseMethods().getUserbyEmail(email);

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "User data not found. Please contact support.",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
        return;
      }

      myname = "${querySnapshot.docs[0]["Name"]}";
      myid = "${querySnapshot.docs[0]["Id"]}";
      myimage = "${querySnapshot.docs[0]["Image"]}";

      await SharedpreferenceHelper().saveUserEmail(email);
      await SharedpreferenceHelper().saveUserImage(myimage);
      await SharedpreferenceHelper().saveUserDisplayName(myname);
      await SharedpreferenceHelper().saveUserId(myid);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "No user found for that email",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Wrong password provided",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Login error: ${e.message}",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "An error occurred: $e",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView( // Added SingleChildScrollView to fix overflow
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(180)),
                  child: Image.asset(
                    "images/login.png",
                    height: 350,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 40.0),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Email",
                  style: TextStyle(
                      color: const Color.fromARGB(186, 255, 255, 255),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 30.0),
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(174, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: mailcontroller,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Password",
                  style: TextStyle(
                      color: const Color.fromARGB(186, 255, 255, 255),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 30.0),
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(174, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  obscureText: true,
                  controller: passwordcontroller,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: const Color.fromARGB(186, 255, 255, 255),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: (){
                  if(mailcontroller.text != "" && passwordcontroller.text != ""){
                    setState(() {
                      email = mailcontroller.text;
                      password = passwordcontroller.text;
                    });
                    userLogin();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.orangeAccent,
                        content: Text(
                          "Please enter email and password",
                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                        )));
                  }
                },
                child: Container(
                  height: 50,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color(0xfffc9502),
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Center(
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(
                      color: Color.fromARGB(173, 255, 255, 255),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Center(
                  child: Text(
                    "Signup",
                    style: TextStyle(
                        color: Color(0xfffea720),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20.0), // Added padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}