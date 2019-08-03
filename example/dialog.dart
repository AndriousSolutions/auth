///
/// Copyright (C) 2019 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  01 Aug 2019
///
///

import 'dart:async';

import 'package:flutter/material.dart';

// Creates an alertDialog for the user to enter their email
Future<List<String>> dialogBox({
  Key key,
  @required BuildContext context,
  bool barrierDismissible = false,
}) {
  return showDialog<List<String>>(
    context: context,
    barrierDismissible: barrierDismissible, // user must tap button!
    builder: (BuildContext context) {
      return CustomAlertDialog(
        key: key,
        title: "Email & Password",
      );
    },
  );
}

class CustomAlertDialog extends StatefulWidget {
  final String title;
  const CustomAlertDialog({Key key, this.title}) : super(key: key);

  @override
  CustomAlertDialogState createState() => CustomAlertDialogState();
}

class CustomAlertDialogState extends State<CustomAlertDialog> {
  final _resetKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _resetValidate = false;
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        title: Text(widget.title),
        elevation: 20.0,
        content: SingleChildScrollView(
          child: Form(
            key: _resetKey,
            autovalidate: _resetValidate,
            child: ListBody(
              children: <Widget>[
                Text(
                  "Email Address & Password.",
                  style: TextStyle(fontSize: 14.0),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Column(
                  children: <Widget>[
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Icon(
                          Icons.email,
                          size: 20.0,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          validator: validateEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              contentPadding:
                                  EdgeInsets.only(left: 70.0, top: 15.0),
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 14.0)),
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ]),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        validator: (String value) {
                          if (value.length == 0 || value.isEmpty)
                            return "Password required.";
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        controller: _passwordController,
                        obscureText:
                            _hidePassword, //This will obscure text dynamically
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          // Here is key idea
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              'SEND EMAIL',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _onPressed();
            },
          ),
        ],
      ),
    );
  }

  void _onPressed() {
    bool valid = true;

    if (!_resetKey.currentState.validate()) {
      valid = false;
    }

    if (valid) {
      Navigator.of(context)
          .pop([_emailController.text, _passwordController.text]);
    } else {
      _resetValidate = true;
      setState(() {});
    }
  }
}

String validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(pattern);
  if (value.length == 0) {
    return "Email is required";
  } else if (!regExp.hasMatch(value)) {
    return "Invalid Email";
  } else {
    return null;
  }
}
