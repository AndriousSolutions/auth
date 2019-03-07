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
///           Created  10 May 2018
///
/// Github: https://github.com/AndriousSolutions/auth
///
library auth;

import 'dart:async';
import 'package:meta/meta.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

typedef void GoogleListener(GoogleSignInAccount event);
typedef void FireBaseListener(FirebaseUser user);
typedef Future<FirebaseUser> FireBaseUser();

class Auth {
  static FirebaseAuth _fireBaseAuth;
  static GoogleSignIn _googleSignIn;

  static FirebaseUser _user;
  static FirebaseUser get user => _user;

  static Exception _ex;
  static Exception get ex => _ex;
  static String get message => _ex.toString() ?? '';

  static StreamSubscription<FirebaseUser> _firebaseListener;
  static StreamSubscription<GoogleSignInAccount> _googleListener;

  static void init({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    void listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
    void listener(FirebaseUser user),
  }) {
    initFireBase(listener);

    if (_googleSignIn == null ||
        signInOption != null ||
        scopes != null ||
        hostedDomain != null) {
      _signInOption = signInOption ?? _signInOption;
      _scopes = scopes ?? _scopes;
      _hostedDomain = hostedDomain ?? _hostedDomain;

      _googleSignIn = GoogleSignIn(
          signInOption: _signInOption,
          scopes: _scopes,
          hostedDomain: _hostedDomain);
    }

    initListen(
        listen: listen,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  static SignInOption _signInOption;
  static List<String> _scopes;
  static String _hostedDomain;
  static Function _onError;
  static Function _onDone;
  static bool _cancelOnError;

  static List<GoogleListener> _googleListeners = [];
  static bool _googleRunning = false;

  static void initListen({
    void listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) async {
    assert(_googleSignIn != null,
        "Class Auth: _googleSignIn must be initialized!");

    if (listen != null) _googleListeners.add(listen);
    _onError = onError ?? _onError;
    _onDone = onDone ?? _onDone;
    _cancelOnError = cancelOnError ?? _cancelOnError;

    if (_googleListener != null) await _googleListener.cancel();
    _googleListener = _googleSignIn.onCurrentUserChanged.listen(
        _listGoogleListeners,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: _cancelOnError);
  }

  /// async so you'll come back if there's a setState() called in the listener.
  static void _listGoogleListeners(GoogleSignInAccount event) async {
    if (_googleRunning) return;
    _googleRunning = true;
    for (var listener in _googleListeners) {
      listener(event);
    }
    _googleRunning = false;
  }

  static set googleListener(GoogleListener f) => _googleListeners.add(f);

  static removeListen(GoogleListener f) => _googleListeners.remove(f);

  static initFireBase([void listener(FirebaseUser user)]) {
    if (_fireBaseAuth == null) {
      _fireBaseAuth = FirebaseAuth.instance;
      _firebaseListener =
          _fireBaseAuth.onAuthStateChanged.listen(_listFireBaseListeners);
    }
    if (listener != null) {
      _fireBaseListeners.add(listener);
    }
  }

  static List<FireBaseListener> _fireBaseListeners = [];
  static bool _firebaseRunning = false;

  static void _listFireBaseListeners(FirebaseUser event) async {
    if (_firebaseRunning) return;
    _firebaseRunning = true;
    for (var listener in _fireBaseListeners) {
      listener(event);
    }
    _firebaseRunning = false;
  }

  static set fireBaseListener(FireBaseListener f) => _fireBaseListeners.add(f);

  static removeListener(FireBaseListener f) => _fireBaseListeners.remove(f);

  static dispose() async {
    signOut();
    _user = null;
    _fireBaseAuth = null;
    _googleSignIn = null;
    _fireBaseListeners = null;
    _googleListeners = null;
    if (_googleListener != null) await _googleListener.cancel();
    if (_firebaseListener != null) await _firebaseListener.cancel();
    _googleListener = null;
    _firebaseListener = null;
  }

  static set signInOption(SignInOption v) {
    if (v == null) _signInOption = null;
    init(signInOption: v);
  }

  static set scopes(List<String> v) {
    if (v == null) _scopes = null;
    init(scopes: v);
  }

  static set hostedDomain(String v) {
    if (v == null) _hostedDomain = null;
    init(hostedDomain: v);
  }

  static set listen(Function f) => Auth.googleListener = f;

  static set onError(Function f) {
    if (f == null) _onError = null;
    initListen(onError: f);
  }

  static set onDone(Function f) {
    if (f == null) _onDone = null;
    initListen(onDone: f);
  }

  static set cancelOnError(bool b) => initListen(cancelOnError: b);

  static set listener(Function f) => Auth.fireBaseListener = f;

  static Future<bool> alreadyLoggedIn([GoogleSignInAccount googleUser]) async {
    FirebaseUser fireBaseUser;
    if (_fireBaseAuth != null) fireBaseUser = await _fireBaseAuth.currentUser();
    return _user != null &&
        fireBaseUser != null &&
        _user.uid == fireBaseUser.uid &&
        (googleUser == null ||
            googleUser.id == fireBaseUser?.providerData[1]?.uid);
  }

  /// Firebase Login.
  static Future<bool> signInAnonymously(
      [void listener(FirebaseUser user)]) async {
    initFireBase(listener);

    FirebaseUser user;
    try {
      user = await _fireBaseAuth.signInAnonymously();
      await _setUserFromFireBase(user);
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    // Must return null until 'awaits' are completed. -gp
    return user?.uid?.isNotEmpty;
  }

  static Future<bool> createUserWithEmailAndPassword(
      {@required String email,
      @required String password,
      void listener(FirebaseUser user)}) async {
    initFireBase(listener);

    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    FirebaseUser user;
    try {
      user = await _fireBaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((usr) {
        _setUserFromFireBase(usr);
        return usr;
      });
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }

  static Future<List<String>> fetchSignInMethodsForEmail({
    @required String email,
  }) async {
    List<String> providers;

    try {
      providers = await _fireBaseAuth?.fetchSignInMethodsForEmail(email: email);
    } catch (ex) {
      _ex = ex;
      providers = null;
    }
    return providers;
  }

  static Future<bool> sendPasswordResetEmail({
    @required String email,
  }) async {
    bool reset;
    try {
      await _fireBaseAuth?.sendPasswordResetEmail(email: email);
      reset = true;
    } catch (ex) {
      _ex = ex;
      reset = false;
    }
    return reset;
  }

  static Future<bool> signInWithEmailAndPassword(
      {@required String email,
      @required String password,
      void listener(FirebaseUser user)}) async {
    initFireBase(listener);

    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    FirebaseUser user;
    try {
      user = await _fireBaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((usr) {
        _setUserFromFireBase(usr);
        return usr;
      });
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }

  static Future<bool> signInWithCredential(
      {@required AuthCredential credential,
      void listener(FirebaseUser user)}) async {
    initFireBase(listener);

    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    FirebaseUser user;
    try {
      user = await _fireBaseAuth.signInWithCredential(credential).then((usr) {
        _setUserFromFireBase(usr);
        return usr;
      });
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }

  static Future<bool> signInWithCustomToken(
      {@required String token, void listener(FirebaseUser user)}) async {
    initFireBase(listener);

    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    FirebaseUser user;
    try {
      user =
          await _fireBaseAuth.signInWithCustomToken(token: token).then((usr) {
        _setUserFromFireBase(usr);
        return usr;
      });
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user != null;
  }

  static Future<FirebaseUser> fireBaseUser() async {
    FirebaseUser user;
    try {
      user = await _fireBaseAuth?.currentUser();
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user;
  }

  // Update from firebase_auth 0.6.2+1
  static Future<void> updateProfile(UserUpdateInfo userUpdateInfo) =>
      _user?.updateProfile(userUpdateInfo);

  static Future<FirebaseUser> linkWithCredential(
      AuthCredential credential) async {
    FirebaseUser user;
    try {
      user = await _fireBaseAuth?.linkWithCredential(credential);
    } catch (ex) {
      _ex = ex;
      user = null;
    }
    return user;
  }

  static Future<bool> _setUserFromFireBase(FirebaseUser user) async {
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

  /// Log into Firebase using Google
  static Future<bool> logInWithGoogle({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    Null listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
    Null listener(FirebaseUser user),
  }) async {
    init(
        signInOption: signInOption,
        scopes: scopes,
        hostedDomain: hostedDomain,
        listen: listen,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
        listener: listener);

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Attempt to sign in without user interaction
        currentUser = await _googleSignIn.signInSilently();
        await _setFireBaseUserFromGoogle(currentUser);
        _listGoogleListeners(currentUser);
      } catch (ex) {
        _ex = ex;
        currentUser = null;
      }
    }

    if (currentUser == null) {
      try {
        // Force the user to interactively sign in
        currentUser = await _googleSignIn.signIn();
        await _setFireBaseUserFromGoogle(currentUser);
        _listGoogleListeners(currentUser);
      } catch (ex) {
        _ex = ex;
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signIn();
        } else {
          currentUser = null;
        }
      }
    } else {
      final loggedIn = await alreadyLoggedIn(currentUser);
      if (!loggedIn) await _setFireBaseUserFromGoogle(currentUser);
    }
    return currentUser != null;
  }

  /// Sign into Google
  static Future<bool> signInSilently({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    Null listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
    bool suppressErrors = true,
  }) async {
    init(
      signInOption: signInOption,
      scopes: scopes,
      hostedDomain: hostedDomain,
      listen: listen,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Attempt to sign in without user interaction
        currentUser = await _googleSignIn
            .signInSilently(suppressErrors: suppressErrors)
            .catchError((ex) {
          _ex = ex;
        }).then((user) {
          _setFireBaseUserFromGoogle(user).then((set) {
            _listGoogleListeners(user);
          });
          return user;
        }).catchError((ex) {
          _ex = ex;
        });
      } catch (ex) {
        _ex = ex;
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signInSilently();
        } else {
          currentUser = null;
        }
      }
    } else {
      final loggedIn = await alreadyLoggedIn(currentUser);
      if (!loggedIn) await _setFireBaseUserFromGoogle(currentUser);
    }
    return currentUser != null;
  }

  /// Sign into Google
  static Future<bool> signIn({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    Null listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) async {
    init(
      signInOption: signInOption,
      scopes: scopes,
      hostedDomain: hostedDomain,
      listen: listen,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Force the user to interactively sign in
        currentUser = await _googleSignIn.signIn();
        await _setFireBaseUserFromGoogle(currentUser);
        _listGoogleListeners(currentUser);
      } catch (ex) {
        _ex = ex;
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signIn();
        } else {
          currentUser = null;
        }
      }
    } else {
      final loggedIn = await alreadyLoggedIn(currentUser);
      if (!loggedIn) await _setFireBaseUserFromGoogle(currentUser);
    }
    return currentUser != null;
  }

  static Future<bool> _setFireBaseUserFromGoogle(
      GoogleSignInAccount currentUser) async {
    final GoogleSignInAuthentication auth = await currentUser?.authentication;

    FirebaseUser user;

    if (auth == null) {
      user = null;
    } else {
      try {
        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        user = await _fireBaseAuth.signInWithCredential(credential);
      } catch (ex) {
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

    final id = user?.uid ?? '';

    return id.isNotEmpty;
  }

  static Future<Null> signOut() async {
    // Sign out with FireBase
    await _fireBaseAuth?.signOut();
    // Sign out with google
    // Does not disconnect however.
    await _googleSignIn?.signOut();
  }

  static Future<GoogleSignInAccount> disconnect() async {
    await signOut();
    // Disconnect from Google
    return _googleSignIn?.disconnect();
  }

  /// Google Signed in.
  static bool isSignedIn() => _fireBaseAuth?.currentUser() != null;

  /// FireBase Logged in.
  static bool isLoggedIn() => _user != null;

  /// Access to the GoogleSignIn Object
  static GoogleSignIn get googleSignIn {
    init();
    return _googleSignIn;
  }

  /// The currently signed in account, or null if the user is signed out.
  static GoogleSignInAccount get googleUser {
    init();
    return _googleSignIn?.currentUser;
  }

  static Future<bool> sendEmailVerification() => _user?.sendEmailVerification();

  /// refreshes the data of the current user
  static Future<bool> reload() async {
    await _user?.reload();
    return _setUserFromFireBase(_user);
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
}
