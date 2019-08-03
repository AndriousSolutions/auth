// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart' show GoogleUserCircleAvatar;

import 'package:auth/auth.dart';

import 'dialog.dart';

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
