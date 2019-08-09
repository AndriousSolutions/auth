// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart' show GoogleUserCircleAvatar;

import 'package:auth/auth.dart';

void main() {
  runApp(
    MaterialApp(
      home: SignInDemo(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo>
    with SingleTickerProviderStateMixin {
  Auth auth;
  bool loggedIn = false;
  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    auth = Auth.init(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
        listener: (user) {
          loggedIn = user != null;
          setState(() {});
        });

    auth.signInSilently(
      listen: (account) {
        loggedIn = account != null;
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    /// Important to dispose of the Auth's resources.
    auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign In Demo"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Sign In"),
              Tab(text: "Results"),
            ],
            controller: tabController,
          ),
        ),
        body: Center(
          child: TabBarView(
            controller: tabController,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: _buildBody(),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: _authResults,
              ),
            ],
          ),
        ));
  }

  Widget _buildBody() {
    if (loggedIn) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: auth.signedInGoogle()
                ? GoogleUserCircleAvatar(
                    identity: auth.googleUser,
                  )
                : Text(''),
            title: Text(auth.displayName),
            subtitle: Text(auth.email),
          ),
          const Text("Signed in successfully."),
          RaisedButton(
            child: const Text('Sign Out'),
            onPressed: () {
              auth.signOut();
            },
          ),
          RaisedButton(
            child: const Text('Sign Out & Disconnect'),
            onPressed: () {
              auth.disconnect();
            },
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('Sign In With Google'),
            onPressed: () {
              auth.signIn();
            },
          ),
          RaisedButton(
            child: const Text('Log in anonymously'),
            onPressed: () {
              auth.signInAnonymously();
            },
          ),
          RaisedButton(
            child: const Text('Sign in with Email & Password'),
            onPressed: () async {
              List<String> ep = await dialogBox(context: context);
              if (ep == null || ep.isEmpty) return;
              auth.signInWithEmailAndPassword(email: ep[0], password: ep[1]);
            },
          ),
        ],
      );
    }
  }

  Widget get _authResults => ListView(
        padding: const EdgeInsets.all(30.0),
        itemExtent: 80.0,
        children: <Widget>[
          Text("uid: ${auth.uid}"),
          Text("name: ${auth.displayName}"),
          Text("photo: ${auth.photoUrl}"),
          Text("new login: ${auth.isNewUser}"),
          Text("user name: ${auth.username}"),
          Text("email: ${auth.email}"),
          Text("email verified: ${auth.isEmailVerified}"),
          Text("anonymous login: ${auth.isAnonymous}"),
          Text("id token: ${auth.idToken}"),
          Text("access token: ${auth.accessToken}"),
          Text("information provider: ${auth.providerId}"),
          Text("expire time: ${auth.expirationTime}"),
          Text("auth time: ${auth.authTime}"),
          Text("issued at: ${auth.issuedAtTime}"),
          Text("signin provider: ${auth.signInProvider}"),
        ],
      );
}

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
