// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auth/auth.dart'
    if (dart.library.html) 'package:auth/auth_web.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show SystemChannels, TextInputType;

/// To log into Firebase
import 'package:example/firebase_options.dart';

import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart';

void main() => runApp(
      const MaterialApp(
        home: SignInDemo(),
        debugShowCheckedModeBanner: false,
      ),
    );

///
class SignInDemo extends StatefulWidget {
  ///
  const SignInDemo({Key? key}) : super(key: key);
  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo>
    with SingleTickerProviderStateMixin {
  late Auth auth;
  bool loggedIn = false;
  late TabController tabController;
  String errorMessage = '';
  TextSpan? errorSpan;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    auth = Auth(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
        firebaseOptions: DefaultFirebaseOptions.currentPlatform,
        listener: (user) {
          loggedIn = user != null;
          errorMessage = auth.message;
          setState(() {});
        });

    auth.signInSilently(
      listen: (account) {
        loggedIn = account != null;
        errorMessage = auth.message;
        setState(() {});
      },
      listener: (user) {
//        final test = user != null;
      },
    );

    loggedIn = auth.isLoggedIn();
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
          title: const Text('Sign In Demo'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Sign In'),
              Tab(text: 'Results'),
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
                    identity: auth.googleUser!,
                  )
                : const Text(''),
            title: Text(auth.displayName),
            subtitle: Text(auth.email),
          ),
          const Text('Signed in successfully.'),
          signInErrorMsg,
          ElevatedButton(
            onPressed: () {
              auth.signOut();
            },
            child: const Text('Sign Out of Firebase'),
          ),
          ElevatedButton(
            onPressed: () {
              auth.disconnect();
            },
            child: const Text('Sign Out & Disconnect'),
          ),
          ElevatedButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: const Text('Just Quit'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          signInErrorMsg,
          ElevatedButton(
            onPressed: () {
              auth.signInWithFacebook().then((signIn) {
                return signInFunc(method: 'Facebook', signIn: signIn);
              }).catchError((Object err) {
                if (err is! Exception) {
                  err = err.toString();
                }
                errorMessage = auth.message;
              });
            },
            child: const Text('Sign In With Facebook'),
          ),
          ElevatedButton(
            onPressed: () {
              auth
                  .signInWithTwitter(
                      key: 'ab1cefgh23KlmnOpQ4STUVWx5',
                      secret:
                          'ab1cefgh23KlmnOpQ4STUVWx5y6ZabCDe7ghi8jKLMnOP9qRst')
                  .then(
                      (signIn) => signInFunc(method: 'Twitter', signIn: signIn))
                  .catchError((Object err) {
                if (err is! Exception) {
                  err = err.toString();
                }
                errorMessage = auth.message;
              });
            },
            child: const Text('Sign In With Twitter'),
          ),
          ElevatedButton(
            onPressed: () {
              auth
                  .signInWithGoogle()
                  .then(
                      (signIn) => signInFunc(method: 'Google', signIn: signIn))
                  .catchError((Object err) {
                if (err is! Exception) {
                  err = err.toString();
                }
                errorMessage = auth.message;
              });
            },
            child: const Text('Sign In With Google'),
          ),
          ElevatedButton(
            onPressed: () {
              auth
                  .signInAnonymously()
                  .then((signIn) =>
                      signInFunc(method: 'Anonymously', signIn: signIn))
                  .catchError((Object err) {
                if (err is! Exception) {
                  err = err.toString();
                }
                errorMessage = auth.message;
              });
            },
            child: const Text('Log in anonymously'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ep = await dialogBox(context: context);
              if (ep == null || ep.isEmpty) {
                return;
              }
              await auth
                  .signInWithEmailAndPassword(email: ep[0], password: ep[1])
                  .then((signIn) =>
                      signInFunc(method: 'By email', signIn: signIn))
                  .catchError((Object err) {
                if (err is! Exception) {
                  err = err.toString();
                }
                errorMessage = auth.message;
              });
            },
            child: const Text('Sign in with Email & Password'),
          ),
        ],
      );
    }
  }

  // This function is called by every RaisedButton widget.
  void signInFunc({required String method, required bool signIn}) {
    //
    if (signIn) {
      errorMessage = '';
    } else {
      errorMessage = auth.message;
    }

    // Not to be display at this time.
    errorSpan = null;

    // Specific error messages
    if (errorMessage.contains('implementation') ||
        errorMessage.contains('APIKey') ||
        errorMessage.contains('record')) {
      //
      Uri? uri;

      errorMessage = "$method login is not implemented.";

      if (method == 'Facebook') {
        //
        uri = Uri.https(
            'google.com', '/search', {'q': 'Firebase Flutter Facebook'});
        //           "\r\nhttps://www.google.com/search?q='Firebase' 'Flutter' 'Facebook app'";

      } else if (method == 'Twitter') {
        //
        uri = Uri.https(
            'google.com', '/search', {'q': 'Firebase Flutter Twitter'});
//            "\r\nhttps://www.google.com/search?q='Firebase' 'Flutter' 'Twitter app'";

      } else if (method == 'By email') {
        //
        errorMessage =
            '$errorMessage\r\nTry  test@testing.com password: 123456';

        uri = Uri.https(
            'google.com', '/search', {'q': 'Firebase Flutter Email Password'});
//            "\r\nhttps://www.google.com/search?q='Firebase' 'Flutter' 'Email' 'Password'";
      }

      if (uri != null) {
        //
        errorSpan = TextSpan(
          text: 'More info.',
          style: const TextStyle(color: Colors.blue, fontSize: 20),
          recognizer: TapGestureRecognizer()..onTap = () => launchUrl(uri!),
        );
      }
    }

    setState(() {});
  }

  Widget get _authResults => ListView(
        padding: const EdgeInsets.all(30),
        itemExtent: 80,
        children: <Widget>[
          Text('uid: ${auth.uid}'),
          Text('name: ${auth.displayName}'),
          Text('photo: ${auth.photoUrl}'),
          Text('new login: ${auth.isNewUser}'),
          Text('user name: ${auth.username}'),
          Text('email: ${auth.email}'),
          Text('email verified: ${auth.isEmailVerified}'),
          Text('anonymous login: ${auth.isAnonymous}'),
//          Text('permissions: ${auth.permissions}'),
          Text('id token: ${auth.idToken}'),
          Text('access token: ${auth.accessToken}'),
          Text('information provider: ${auth.providerId}'),
          Text('expire time: ${auth.expirationTime}'),
          Text('auth time: ${auth.authTime}'),
          Text('issued at: ${auth.issuedAtTime}'),
          Text('signin provider: ${auth.signInProvider}'),
        ],
      );

  Widget get signInErrorMsg => Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  text: errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ),
              if (errorSpan != null) RichText(text: errorSpan!),
            ],
          ),
        ),
      );
}

// Creates an alertDialog for the user to enter their email
Future<List<String>?> dialogBox({
  Key? key,
  required BuildContext context,
  bool barrierDismissible = false,
}) {
  return showDialog<List<String>>(
    context: context,
    barrierDismissible: barrierDismissible, // user must tap button!
    builder: (BuildContext context) {
      return CustomAlertDialog(
        key: key,
        title: 'Email & Password',
      );
    },
  );
}

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  final _resetKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _resetValidate = false;
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      elevation: 20,
      content: SingleChildScrollView(
        child: Form(
          key: _resetKey,
          autovalidateMode: _resetValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListBody(
            children: <Widget>[
              const Text(
                'Email Address & Password.',
                style: TextStyle(fontSize: 14),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              Column(
                children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.email,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        validator: validateEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                            contentPadding: EdgeInsets.only(left: 70, top: 15),
                            hintStyle:
                                TextStyle(color: Colors.black, fontSize: 14)),
                        style: const TextStyle(color: Colors.black),
                      ),
                    )
                  ]),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Password required.';
                        }
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
                            // Update the state i.e. google the state of passwordVisible variable
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            _onPressed();
          },
          child: const Text(
            'SEND EMAIL',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _onPressed() {
    var valid = true;

    if (_resetKey.currentState == null || !_resetKey.currentState!.validate()) {
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

String? validateEmail(String? value) {
  if (value == null) {
    return null;
  }
  const pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final regExp = RegExp(pattern);
  if (value.isEmpty) {
    return 'Email is required';
  } else if (!regExp.hasMatch(value)) {
    return 'Invalid Email';
  }
  return null;
}
