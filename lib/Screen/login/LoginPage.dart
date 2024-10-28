import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/login/BusWidget.dart';
import 'package:bakhbade/Screen/login/LoginForm.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 10),
                BusWidget(), // Widget Logo
                LoginForm(), // Widget Formulaire de connexion
                SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
