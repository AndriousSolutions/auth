// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'password.dart';

import 'package:auth/auth.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();

    Auth.init(
      listen: (account) {
        setState(() {
          _currentUser = account;
        });
      },
    );

    Auth.signInSilently();
  }

  @override
  void dispose() {
    Auth.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName),
            subtitle: Text(_currentUser.email),
          ),
          const Text("Signed in successfully."),
          RaisedButton(
            child: const Text('SIGN OUT'),
            onPressed: _signOut,
          ),
          RaisedButton(
            child: const Text('SIGN OUT & DISCONNECT'),
            onPressed: _disconnect,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('GOOGLE SIGN IN'),
            onPressed: _signIn,
          ),
          RaisedButton(
            child: const Text('SIGN IN WITH EMAIL & PASSWORD'),
            onPressed: _signInWithEmailAndPassword,
          ),
          RaisedButton(
            child: const Text('SIGN IN ANONYMOUSLY'),
            onPressed: _signInAnonymously,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Authentication Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }

  void _signOut() {
    Auth.signOut();
  }

  void _disconnect() {
    Auth.disconnect();
  }

  void _signIn() {
    Auth.signIn();
  }

  void _signInWithEmailAndPassword() {
    Auth.signInWithEmailAndPassword(
        email: hiddenEmail, password: hiddenPassword);
  }

  void _signInAnonymously() {
    Auth.signInAnonymously();
  }
}
