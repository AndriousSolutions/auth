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
import 'package:meta/meta.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Auth {

  static FirebaseAuth _fireBaseAuth;
  static GoogleSignIn _googleSignIn;

  static FirebaseUser _user;
  static get user => _user;

  static Exception _ex;
  static get ex => _ex;
  static get message => _ex.toString() ?? 'No Message';



  static void init({SignInOption signInOption,List<String> scopes, String hostedDomain}){
    if(_fireBaseAuth == null) {
      _fireBaseAuth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn(signInOption: signInOption,scopes: scopes,hostedDomain: hostedDomain);
    }
  }



  static dispose() {
    signOut();
    _user = null;
    _fireBaseAuth = null;
    _googleSignIn = null;
  }



  static Future<bool> alreadyLoggedIn([GoogleSignInAccount googleUser]) async {
    final FirebaseUser fireBaseUser = await _fireBaseAuth?.currentUser();
    return _user != null && fireBaseUser != null && _user.uid == fireBaseUser.uid && (googleUser == null || googleUser.id == fireBaseUser?.providerData[1]?.uid);
  }



  /// Firebase Login.
  static Future<bool> signInAnonymously() async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInAnonymously().then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<bool> createUserWithEmailAndPassword({@required String email,@required String password,}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.createUserWithEmailAndPassword(email: email, password: password).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<List<String>> fetchProvidersForEmail({@required String email,}) => _fireBaseAuth?.fetchProvidersForEmail(email: email);



  static  Future<void> sendPasswordResetEmail({@required String email,}) => _fireBaseAuth?.sendPasswordResetEmail(email: email);



  static  Future<bool> signInWithEmailAndPassword({@required String email, @required String password,}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInWithEmailAndPassword(email: email, password: password).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<bool> signInWithFacebook({@required String accessToken}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInWithFacebook(accessToken: accessToken).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<bool> signInWithTwitter({@required String authToken,@required String authTokenSecret,}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInWithTwitter(authToken: authToken, authTokenSecret: authTokenSecret).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<bool> signInWithGoogle({@required String idToken,@required String accessToken,}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInWithGoogle(idToken: idToken, accessToken: accessToken).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<bool> signInWithCustomToken({@required String token}) async {

    init();

    final loggedIn = await alreadyLoggedIn();
    if(loggedIn) return loggedIn;

    FirebaseUser user;
    try{
      user = await _fireBaseAuth.signInWithCustomToken(token: token).then(
          (usr){
            _setUserFromFirebase(usr);
            return usr;
          }
      );
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }



  static Future<FirebaseUser> fireBaseUser() => _fireBaseAuth.currentUser();

  static Future<FirebaseUser> linkWithEmailAndPassword({@required String email,@required String password,}) => _fireBaseAuth?.linkWithEmailAndPassword(email: email, password: password);

  static Future<void> updateProfile(UserUpdateInfo userUpdateInfo) => _fireBaseAuth?.updateProfile(userUpdateInfo);

  static Future<FirebaseUser> linkWithGoogleCredential({@required String idToken,@required String accessToken,}) => _fireBaseAuth?.linkWithGoogleCredential(idToken: idToken, accessToken: accessToken);

  static  Future<FirebaseUser> linkWithFacebookCredential({@required String accessToken,}) => _fireBaseAuth?.linkWithFacebookCredential(accessToken: accessToken);



  static Future<bool> _setUserFromFirebase(FirebaseUser user) async {

    _idToken = await user?.getIdToken() ?? '';

    _accessToken = '';

    _isEmailVerified = user?.isEmailVerified ?? false;

    _isAnonymous = user?.isAnonymous ?? true;

    _providerId = user?.providerData[0]?.providerId ?? '';

    _uid = user?.providerData[0]?.uid ?? '';

    _displayName = user?.providerData[0]?.displayName ?? '';

    _photoUrl = '';

    _email = user?.providerData[0]?.email ?? '';

    _user = user;

    var id = _user?.uid ?? '';

    return id.isNotEmpty;
  }


    /// Log into Google and into Firebase.
    static Future<bool> logInWithGoogle({SignInOption signInOption,List<String> scopes, String hostedDomain}) async {

      init(signInOption: signInOption,scopes: scopes, hostedDomain: hostedDomain);

      // Attempt to get the currently authenticated user
      GoogleSignInAccount currentUser = _googleSignIn.currentUser;

      if (currentUser == null) {
        try {
          // Attempt to sign in without user interaction
          currentUser = await _googleSignIn.signInSilently().then(
                  (user){
                _setFirebaseUserFromGoogle(user);
                return user;
              }
          );
        }catch(ex){
          _ex = ex;
          currentUser = null;
        }
      }

      if (currentUser == null) {
        try {
          // Force the user to interactively sign in
          currentUser = await _googleSignIn.signIn().then(
                  (user){
                _setFirebaseUserFromGoogle(user);
                return user;
              }
          );
        }catch(ex){
          _ex = ex;
          currentUser = null;
        }
      }else{
        final loggedIn = await alreadyLoggedIn(currentUser);
        if(!loggedIn) await _setFirebaseUserFromGoogle(currentUser);
      }
      return currentUser != null;
    }


    /// Sign into Google
    static Future<bool> signInSilently({SignInOption signInOption,List<String> scopes, String hostedDomain}) async {

      init(signInOption: signInOption,scopes: scopes, hostedDomain: hostedDomain);

      // Attempt to get the currently authenticated user
      GoogleSignInAccount currentUser = _googleSignIn.currentUser;

      if (currentUser == null) {
        try {
          // Attempt to sign in without user interaction
          currentUser = await _googleSignIn.signInSilently().then(
                  (user){
                _setFirebaseUserFromGoogle(user);
                return user;
              }
          );
        } catch (ex) {
          _ex = ex;
          currentUser = null;
        }
      }else{
        final loggedIn = await alreadyLoggedIn(currentUser);
        if(!loggedIn) await _setFirebaseUserFromGoogle(currentUser);
      }
      return currentUser != null;
    }



    /// Sign into Google
    static Future<bool> signIn({SignInOption signInOption,List<String> scopes, String hostedDomain}) async {

      init(signInOption: signInOption,scopes: scopes, hostedDomain: hostedDomain);

      // Attempt to get the currently authenticated user
      GoogleSignInAccount currentUser = _googleSignIn.currentUser;

      if (currentUser == null) {
        try {
          // Force the user to interactively sign in
          currentUser = await _googleSignIn.signIn().then(
              (user){
                _setFirebaseUserFromGoogle(user);
                return user;
              }
          );
        } catch (ex) {
          _ex = ex;
          currentUser = null;
        }
      }else{
        final loggedIn = await alreadyLoggedIn(currentUser);
        if(!loggedIn) await _setFirebaseUserFromGoogle(currentUser);
      }
      return currentUser != null;
    }



  static Future<bool> _setFirebaseUserFromGoogle(GoogleSignInAccount currentUser) async {

    final GoogleSignInAuthentication auth = await currentUser?.authentication;

    FirebaseUser user;

    if(auth == null){
      user = null;
    }else {
       try{
          // Authenticate with FireBase
          user = await _fireBaseAuth.signInWithGoogle(
            idToken: auth.idToken,
            accessToken: auth.accessToken,
          );
       }catch(ex){
         _ex = ex;
         user = null;
       }
    }

    _idToken = auth?.idToken ?? await user?.getIdToken() ?? '';

    _accessToken = auth?.accessToken ?? '';

    _isEmailVerified = user?.email?.isNotEmpty ?? false;

    _isAnonymous = user?.isAnonymous ?? true;

    _providerId = user?.providerId ?? '';

    _uid = user?.uid ?? '';

    _displayName = user?.displayName ?? '';

    _photoUrl = user?.photoUrl ?? '';

    _email = user?.email ?? '';

    _user = user;

    var id = user?.uid ?? '';

    return id.isNotEmpty;
  }



  static Future<Null> signOut() async {
    // Sign out with FireBase
    await _fireBaseAuth.signOut();
    // Sign out with google
    // Does not disconnect however.
    await _googleSignIn.signOut();
  }



  static Future<GoogleSignInAccount> disconnect(){
    // Sign out with FireBase
    _fireBaseAuth.signOut();
    // Disconnect from Google
    return _googleSignIn.disconnect();
  }



  /// Google Signed in.
  static bool isSignedIn() => _fireBaseAuth?.currentUser() != null;

  /// FireBase Logged in.
  static bool isLoggedIn() => _user != null;

  /// Access to the GoogleSignIn Object
  static GoogleSignIn get googleSignIn{
    init();
    return _googleSignIn;
  }

  /// Subscribe to this stream to be notified when the current user changes.
  static Stream<GoogleSignInAccount> get onCurrentUserChanged {
    init();
    return _googleSignIn?.onCurrentUserChanged;
  }

  /// The currently signed in account, or null if the user is signed out.
  static  GoogleSignInAccount get googleUser {
    init();
    return _googleSignIn?.currentUser;
  }





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

  static String _idToken = '';
  static String get idToken => _idToken;

  static String _accessToken = '';
  static String get accessToken => _accessToken;


  Stream<FirebaseUser> get onAuthStateChanged => _fireBaseAuth?.onAuthStateChanged;
}
