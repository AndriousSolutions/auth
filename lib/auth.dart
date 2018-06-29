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
  
  static FirebaseAuth _auth;
  static GoogleSignIn _googleSignIn;

  static FirebaseUser _user;
  static get user => _user;

  static String _tokenId;
  static get idToken => _tokenId;


  static dispose() => signOut();


  static void _init(){
    if(_auth == null) {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    }
  }



  /// Firebase Login.
  static Future<bool> signInAnonymously() async {

    _init();

    final currentUser = await _auth.currentUser();

    if(_user?.uid != currentUser.uid) {

      final FirebaseUser user = await _auth.signInAnonymously();

      _tokenId = await user?.getIdToken() ?? '';

      _isEmailVerified = user?.isEmailVerified;

      _isAnonymous = user?.isAnonymous;

      if (Platform.isIOS) {
        // Anonymous auth doesn't show up as a provider on iOS
        assert(user?.providerData?.isEmpty == true);
      } else if (Platform.isAndroid) {
        // Anonymous auth does show up as a provider on Android
        assert(user?.providerData?.length == 1);

        _providerId = user?.providerData[0]?.providerId ?? '';

        _uid = user?.providerData[0]?.uid ?? '';

        _displayName = user?.providerData[0]?.displayName ?? '';

        _email = user?.providerData[0]?.email ?? '';
      }

      _user = user;
    }

    var id = _user?.uid ?? '';

    return id.isNotEmpty;
  }



  static Future<bool> signInWithGoogle() async {

    _init();

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

    _providerId = user?.providerId ?? '';

    _uid = user?.uid ?? '';

    _displayName = user?.displayName ?? '';

    _photoUrl = user?.photoUrl ?? '';

    _email = user?.email ?? '';

    _isEmailVerified = _email.isNotEmpty;

    _isAnonymous = user?.isAnonymous;

    _tokenId = await user?.getIdToken() ?? '';

    var thisUser = await _auth.currentUser();

    assert(user?.uid == thisUser.uid);

    _user = user;

    var id = user?.uid ?? '';

    return id.isNotEmpty;
  }



  static Future<Null> signOut() async {
    // Sign out with Firebase
    await _auth.signOut();
    // Sign out with google
    await _googleSignIn.signOut();
  }

  static bool isSignedIn() => _auth?.currentUser() != null;

  static bool isLoggedIn() => _user != null;


  static String _providerId = '';
  static String get providerId => _providerId;

  static String _uid = '';
  static String get uid => _uid;

  static String _displayName = '';
  static String get displayName => _displayName;

  static String _photoUrl = '';
  static String get photoUrl => _photoUrl;

  static String _email = '';
  static String get email => _email;

  static bool _isEmailVerified = false;
  static bool get isEmailVerified => _isEmailVerified;

  static bool _isAnonymous = false;
  static bool get isAnonymous => _isAnonymous;


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
}