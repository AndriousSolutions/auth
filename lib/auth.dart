///
/// Copyright (C) 2018 Andrious Solutions
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
///          Created  10 May 2018
///

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Auth {
  
  static init() {

    if(_auth == null){

      _auth = FirebaseAuth.instance;

      _googleSignIn = GoogleSignIn();
    }
  }
  static FirebaseAuth _auth;
  static GoogleSignIn _googleSignIn;


  static FirebaseUser _user;
  get user => _user;


  static dispose() => signOutWithGoogle();


  static Future<String> signInAnonymously() async {

    final currentUser = await _auth.currentUser();
    if(_user?.uid == currentUser.uid) return _user.uid;

    var user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);

    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {

      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }
    
    _user = user;
    return user.uid;
  }


  static Future<String> signInWithGoogle() async {
//
//    var currentUser = await _auth.currentUser();
//    if(_user?.uid == currentUser.uid) return _user.uid;
//
//    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//    final GoogleSignInAuthentication googleAuth =
//    await googleUser.authentication;
//
//    var user = await _auth.signInWithGoogle(
//      accessToken: googleAuth.accessToken,
//      idToken: googleAuth.idToken,
//    );

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;
    if (currentUser == null) {
      // Attempt to sign in without user interaction
      currentUser = await _googleSignIn.signInSilently();
    }
    if (currentUser == null) {
      // Force the user to interactively sign in
      currentUser = await _googleSignIn.signIn();
    }

    final GoogleSignInAuthentication auth = await currentUser.authentication;

    // Authenticate with firebase
    final FirebaseUser user = await _auth.signInWithGoogle(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    var thisUser = await _auth.currentUser();
    assert(user.uid == thisUser.uid);
    _user = user;
    return user.uid;
  }


  static Future<Null> signOutWithGoogle() async {
    // Sign out with Firebase
    await _auth.signOut();
    // Sign out with google
    await _googleSignIn.signOut();
  }

  static bool isSignedIn() => _auth?.currentUser() != null;

  static bool isLoggedIn() => _user != null;

  static signOut() => _auth.signOut();

  static String userProfile(String type) {
    return getProfile(_user, type);
  }

  static String getProfile(FirebaseUser user, String type) {
    if (user == null) {
      return '';
    }

    if (type == null) {
      return '';
    }

    String info = '';

    String holder = '';

    // Always return 'the last' available item.
    for (UserInfo profile in user.providerData.reversed) {
      switch (type.trim().toLowerCase()) {
        case "provider":
          holder = profile.providerId;

          break;
        case "userid":
          holder = profile.uid;

          break;
        case "name":
          holder = profile.displayName;

          break;
        case "email":
          holder = profile.email;

          break;
        case "photo":
          try {
            holder = profile.photoUrl.toString();
          } catch (ex) {
            holder = "";
          }

          break;
        default:
          holder = "";
      }

      if (holder != null && holder.isNotEmpty) {
        info = holder;
      }
    }

    return info;
  }


  static String getUid(){

    String userId;

    var user = getUser();

    if (user == null){

      userId = null;
    }else{

      userId = user.uid;
    }

    return userId;
  }


  static FirebaseUser getUser() {

    return _user;
  }


  static String userEmail(){

    return _user?.email;
  }



  static String userName(){

    return _user?.displayName;
  }



  static String userPhoto(){

    return _user?.photoUrl;
  }
}