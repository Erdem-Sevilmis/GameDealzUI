import 'dart:convert';
import '../Data/Game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'FavouritesScreen.dart';
import 'SignupScreen.dart';

class Login extends StatelessWidget {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("Token"));
  }

  Future<bool> _setToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.setString("Token", token));
  }

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final usernameField = TextFormField(
        controller: usernameController,
        obscureText: false,
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
        ));

    final passwordController = TextEditingController();
    final passwordField = TextFormField(
        controller: passwordController,
        obscureText: true,
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
      body: Container(
        padding: EdgeInsets.only(top: 50),
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: 300, maxHeight: 350),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              usernameField,
              passwordField,
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.grey[800],
                      onSurface: Colors.black,
                      shadowColor: Colors.transparent),
                  onPressed: () async {
                    if (usernameController.text != null &&
                        passwordController.text != null) {
                      var formData = {
                        "name": usernameController.text,
                        "password": passwordController.text
                      };
                      var result = await http.post(
                          GameDealz.URL+"api/user/authenticate",
                          body: formData);
                      var stringResult = json.decode(result.body);
                      if (result.statusCode != 200 ||
                          stringResult["success"] == false) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Username or password is wrong.",
                                style: TextStyle(color: Colors.white)),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.black));
                        return stringResult["msg"];
                      }
                      var res = await _getToken();
                      if (res == null) {
                        Map<String, dynamic> convertedToken =
                            jsonDecode(result.body);

                        var success = await _setToken(convertedToken["token"]);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Logged in.",
                                style: TextStyle(color: Colors.white)),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.black));
                      }
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (builder) => Favorites()));
                    }
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  )),
              Column(
                children: [
                  Text("Dont have an account yet? "),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpForm()));
                      },
                      child: Text(
                        "Sign up here",
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
    );
  }
}
