import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'FavouritesScreen.dart';
import 'LoginScreen.dart';


class SignUpForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Signup();
}

class Signup extends State<SignUpForm> {
  final _formKey = new GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("Token"));
  }
  Future<bool> _setToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.setString("Token",token));
  }

  void validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final usernameField = TextFormField(
      controller: usernameController,
      obscureText: false,
      onChanged: (password) {
        _formKey.currentState.validate();
      },
      validator: (String userName) {
        if (userName.isEmpty) return "Username cant be empty.";

        var isUserNameNotValid =
        userName.contains(new RegExp(r'[ !@#$%^&*(),.?":{}|<>]'));

        return isUserNameNotValid
            ? "Your username cant contain any special characters."
            : null;
      },
      decoration: InputDecoration(
        hintText: "Username",
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    );

    final emailController = TextEditingController();
    final emailField = TextFormField(
        controller: emailController,
        obscureText: false,
        onChanged: (password) {
          _formKey.currentState.validate();
        },
        validator: (String value) {
          if (value.isEmpty) return "E-Mail cant be empty.";

          return value.contains('@') && value.contains('.')
              ? null
              : "You have to use a valid E-Mail.";
        },
        decoration: InputDecoration(
          hintText: "Email",
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ));

    final passwordController = TextEditingController();
    final passwordField = TextFormField(
        controller: passwordController,
        obscureText: true,
        onChanged: (password) {
          _formKey.currentState.validate();
        },
        validator: (String password) {
          if (password == null || password.isEmpty) {
            return "Password cant be empty.";
          }

          bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
          bool hasDigits = password.contains(new RegExp(r'[0-9]'));
          bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
          // bool hasSpecialCharacters =
          //     password.contains(new RegExp(r'[ !@#$%^&*(),.?":{}|<>]'));
          bool hasMinLength = password.length > 6;

          return hasDigits &
          hasUppercase &
          hasLowercase &
          // hasSpecialCharacters &
          hasMinLength
              ? null
              : "Password has to be 6 characters long &\ncontain lower, uppercase.";
          //& special characters\n[!@#\$%^&*(),.?:{}|<>]
        },
        decoration: InputDecoration(
          hintText: "Password",
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ));

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 300, maxHeight: 450),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                usernameField,
                emailField,
                passwordField,
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.grey[800],
                        onSurface: Colors.black,
                        shadowColor: Colors.transparent),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        var formData = {
                          "name": usernameController.text,
                          "email": emailController.text,
                          "password": passwordController.text
                        };
                        var result = await http.post(
                            GameDealz.URL+"api/user",
                            body: formData);
                        var stringResult = json.decode(result.body);
                        if (result.statusCode != 201 ||
                            stringResult["success"] == false) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(stringResult["msg"],style: TextStyle(color: Colors.white)),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.black
                          ));
                          return stringResult["msg"];
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Signed up.",style: TextStyle(color: Colors.white)),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.black
                        ));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=> Login()));
                      }
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(color: Colors.white),
                    )),
                Column(
                  children: [
                    Text("Have an account already?"),
                    TextButton(
                        onPressed: () {
                          if (_getToken() != null) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Favorites()));
                          }
                        },
                        child: Text(
                          "Login here",
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}