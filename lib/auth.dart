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

import 'dart:async' show Future, StreamSubscription;
import 'package:flutter/material.dart' show required;
import 'package:firebase_auth/firebase_auth.dart'
    show
        AdditionalUserInfo,
        AuthResult,
        AuthCredential,
        FirebaseAuth,
        FacebookAuthProvider,
        FirebaseUser,
        IdTokenResult,
        GoogleAuthProvider,
        TwitterAuthProvider,
        UserUpdateInfo;
import 'package:google_sign_in/google_sign_in.dart'
    show
        GoogleSignIn,
        GoogleSignInAccount,
        GoogleSignInAuthentication,
        SignInOption;

import 'package:auth/flutteroauth.dart';

typedef void GoogleListener(GoogleSignInAccount event);
typedef void FireBaseListener(FirebaseUser user);
typedef Future<FirebaseUser> FireBaseUser();

class Auth {
  static FirebaseAuth _fireBaseAuth;
  static GoogleSignIn _googleSignIn;

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
    _initFireBase(
        listener: listener,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);

    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn(
          signInOption: signInOption,
          scopes: scopes,
          hostedDomain: hostedDomain);

      _initListen(
          listen: listen,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError);
    }
  }

  static _initFireBase({
    void listener(FirebaseUser user),
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    if (_fireBaseAuth == null) {
      _fireBaseAuth = FirebaseAuth.instance;
      _firebaseListener = _fireBaseAuth.onAuthStateChanged.listen(
          _listFireBaseListeners,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError);
    }
    if (listener != null) {
      _fireBaseListeners.add(listener);
    }
  }

  static Set<FireBaseListener> _fireBaseListeners = Set();
  static bool _firebaseRunning = false;

  static void _listFireBaseListeners(FirebaseUser user) async {
    if (_firebaseRunning) return;
    _firebaseRunning = true;
    await _setUserFromFireBase(user);
    for (var listener in _fireBaseListeners) {
      listener(user);
    }
    _firebaseRunning = false;
  }

  static fireBaseListener(FireBaseListener f) => _fireBaseListeners.add(f);

  static removeListener(FireBaseListener f) => _fireBaseListeners.remove(f);

  static Set<GoogleListener> _googleListeners = Set();
  static bool _googleRunning = false;

  static void _initListen({
    void listen(GoogleSignInAccount event),
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) async {
    if (_googleSignIn != null) {
      if (listen != null) _googleListeners.add(listen);

      if (_googleListener == null) {
        _googleListener = _googleSignIn.onCurrentUserChanged.listen(
            _listGoogleListeners,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError);
      }
    }
  }

  /// async so you'll come back if there's a setState() called in the listener.
  static void _listGoogleListeners(GoogleSignInAccount user) async {
    if (_googleRunning) return;
    _googleRunning = true;
    await _setFireBaseUserFromGoogle(user);
    for (var listener in _googleListeners) {
      listener(user);
    }
    _googleRunning = false;
  }

  static googleListener(GoogleListener f) => _googleListeners.add(f);

  static removeListen(GoogleListener f) => _googleListeners.remove(f);

  static dispose() async {
    signOut();
    _user = null;
    _fireBaseAuth = null;
    _googleSignIn = null;
    _fireBaseListeners = null;
    _googleListeners = null;
    await _googleListener?.cancel();
    await _firebaseListener?.cancel();
    _googleListener = null;
    _firebaseListener = null;
  }

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
  static Future<bool> signInAnonymously({
    void listener(FirebaseUser user),
  }) async {
    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      _result = await _fireBaseAuth.signInAnonymously();
      user = _result?.user;
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      _result = null;
      user = null;
    }
    // Must return null until 'awaits' are completed. -gp
    return user?.uid?.isNotEmpty ?? false;
  }

  static Future<bool> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    void listener(FirebaseUser user),
  }) async {
    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      user = await _fireBaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) {
        _result = result;
        FirebaseUser usr = _result.user;
        return usr;
      });
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      user = null;
      _result = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  static Future<List<String>> fetchSignInMethodsForEmail({
    @required String email,
  }) async {
    List<String> providers;

    try {
      providers = await _fireBaseAuth?.fetchSignInMethodsForEmail(email: email);
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
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
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      reset = false;
    }
    return reset;
  }

  static Future<bool> signInWithEmailAndPassword({
    @required String email,
    @required String password,
    void listener(FirebaseUser user),
  }) async {
    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      user = await _fireBaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((result) {
        _result = result;
        FirebaseUser usr = _result?.user;
        return usr;
      }).catchError((ex) {
        if (ex is! Exception) {
          _ex = Exception(ex.toString());
        } else {
          _ex = ex;
        }
        _result = null;
        user = null;
      });
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  static Future<bool> signInWithCredential({
    @required AuthCredential credential,
    void listener(FirebaseUser user),
  }) async {
    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      user =
          await _fireBaseAuth.signInWithCredential(credential).then((result) {
        _result = result;
        FirebaseUser usr = _result?.user;
        return usr;
      }).catchError((ex) {
        if (ex is! Exception) {
          _ex = Exception(ex.toString());
        } else {
          _ex = ex;
        }
        _result = null;
        user = null;
      });
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  static Future<bool> signInWithCustomToken({
    @required String token,
    void listener(FirebaseUser user),
  }) async {
    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      user = await _fireBaseAuth
          .signInWithCustomToken(token: token)
          .then((result) {
        _result = result;
        FirebaseUser usr = _result?.user;
        return usr;
      });
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  static Future<FirebaseUser> fireBaseUser() async {
    FirebaseUser user;
    try {
      user = await _fireBaseAuth?.currentUser();
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      user = null;
    }
    return user;
  }

  // Update from firebase_auth 0.6.2+1
  static Future<void> updateProfile(UserUpdateInfo userUpdateInfo) {
    Future<void> profile;
    try {
      profile = _user?.updateProfile(userUpdateInfo);
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
    }
    return profile;
  }

  static Future<FirebaseUser> linkWithCredential(
      AuthCredential credential) async {
    FirebaseUser user;
    AuthResult result;

    try {
      result = await _user?.linkWithCredential(credential);
      user = result?.user;
      _result = result;
    } catch (ex) {
      if (ex is! Exception) {
        _ex = Exception(ex.toString());
      } else {
        _ex = ex;
      }
      result = null;
      user = null;
    }
    return user;
  }

  static Future<bool> _setUserFromFireBase(FirebaseUser user) async {
    _user = user;

    _idTokenResult = await user?.getIdToken();

    _idToken = _idTokenResult?.token ?? '';

    _accessToken = '';

    _isEmailVerified = user?.isEmailVerified ?? false;

    _isAnonymous = user?.isAnonymous ?? true;

    _providerId = user?.providerId ?? '';

    _uid = user?.uid ?? '';

    _displayName = user?.displayName ?? '';

    _photoUrl = user?.photoUrl ?? '';

    _email = user?.email ?? '';

    _phoneNumber = user?.phoneNumber ?? '';

    return _uid.isNotEmpty;
  }

  /// Log into Firebase using Google
  static Future<bool> logInWithGoogle({
    Null listen(GoogleSignInAccount user),
  }) async {
    /// Attempt to sign in without user interaction
    bool logIn = await signInSilently(listen: listen, suppressErrors: true);

    if (!logIn) {
      /// Force the user to interactively sign in
      logIn = await signIn(listen: listen);
    }
    return logIn;
  }

  /// Sign into Google
  static Future<bool> signInSilently({
    Null listen(GoogleSignInAccount user),
    bool suppressErrors = true,
  }) async {
    _initListen(listen: listen);

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Attempt to sign in without user interaction
        currentUser = await _googleSignIn
            .signInSilently(suppressErrors: suppressErrors)
            .catchError((ex) {
          if (ex is! Exception) {
            _ex = Exception(ex.toString());
          } else {
            _ex = ex;
          }
        }).then((user) {
          return user;
        }).catchError((ex) {
          if (ex is! Exception) {
            _ex = Exception(ex.toString());
          } else {
            _ex = ex;
          }
        });
      } catch (ex) {
        if (ex is! Exception) {
          _ex = Exception(ex.toString());
        } else {
          _ex = ex;
        }
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
    Null listen(GoogleSignInAccount event),
  }) async {
    _initListen(listen: listen);

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Force the user to interactively sign in
        currentUser = await _googleSignIn.signIn();
      } catch (ex) {
        if (ex is! Exception) {
          _ex = Exception(ex.toString());
        } else {
          _ex = ex;
        }
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
    AuthResult result;

    if (auth == null) {
      user = null;
    } else {
      try {
        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        result = await _fireBaseAuth.signInWithCredential(credential);
        user = result?.user;
      } catch (ex) {
        if (ex is! Exception) {
          _ex = Exception(ex.toString());
        } else {
          _ex = ex;
        }
        result = null;
        user = null;
      }
    }

    bool set = await _setUserFromFireBase(user);

    _result = result;

    _idToken = auth?.idToken ?? '';

    _accessToken = auth?.accessToken ?? '';

    return set;
  }

  static Future<bool> signInWithFacebook(
      {@required String id, @required String secret}) async {
    id ??= "";
    secret ??= "";
    assert(id.isNotEmpty, "Must pass an id to signInWithFacebook() function!");
    assert(secret.isNotEmpty,
        "Must pass the secret to signInWithFacebook() function!");
    if (id.isEmpty || secret.isEmpty) return Future.value(false);
    final OAuth flutterOAuth = FlutterOAuth(Config(
        "https://www.facebook.com/dialog/oauth",
        "https://graph.facebook.com/v2.2/oauth/access_token",
        id,
        secret,
        "http://localhost:8080/",
        "code"));
    Token token = await flutterOAuth.performAuthorization();
    AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: token.accessToken);
    return signInWithCredential(credential: credential);
  }

  static Future<bool> signInWithTwitter(
      {@required String key,
      @required String secret,
      @required String callbackURI}) async {
    key ??= "";
    secret ??= "";
    callbackURI ??= "";
    assert(key.isNotEmpty, "Must pass an key to signInWithTwitter() function!");
    assert(secret.isNotEmpty,
        "Must pass the secret to signInWithTwitter() function!");
    assert(callbackURI.isNotEmpty,
        "Must pass the callback URI to signInWithTwitter() function!");
    if (key.isEmpty || secret.isEmpty || callbackURI.isEmpty)
      return Future.value(false);
    final OAuth flutterOAuth = FlutterOAuth(Config(
        "https://api.twitter.com/oauth/request_token",
        "https://api.twitter.com/oauth/authenticate",
        key,
        secret,
        callbackURI,
        "code"));
    Token accessToken = await flutterOAuth.performAuthorization();
    AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: accessToken.accessToken, authTokenSecret: secret);
    return signInWithCredential(credential: credential);
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
  static Future<bool> isSignedIn() async =>
      await isLoggedIn() && googleSignIn?.currentUser != null;

  /// FireBase Logged in.
  static Future<bool> isLoggedIn() async {
    bool loggedIn = _user?.uid?.isNotEmpty;
    if (!loggedIn) {
      FirebaseUser user = await _fireBaseAuth?.currentUser();
      loggedIn = user?.uid?.isNotEmpty;
    }
    return loggedIn;
  }

  /// Access to the GoogleSignIn Object
  static GoogleSignIn get googleSignIn {
    return _googleSignIn;
  }

  /// The currently signed in account, or null if the user is signed out.
  static GoogleSignInAccount get googleUser {
    return _googleSignIn?.currentUser;
  }

  static Future<void> sendEmailVerification() => _user?.sendEmailVerification();

  /// refreshes the data of the current user
  static Future<bool> reload() async {
    await _user?.reload();
    return _setUserFromFireBase(_user);
  }

  static AuthResult _result;
  static AuthResult get result => _result;

  static FirebaseUser _user;
  static FirebaseUser get user => _user;

  static Exception _ex;
  static Exception get ex => _ex;
  static String get message => _ex?.toString() ?? '';

  /// Get the last error but clear it.
  static Exception getError() {
    Exception e = _ex;
    _ex = null;
    return e;
  }

  static AdditionalUserInfo get userInfo => _result?.additionalUserInfo;

  static bool get isNewUser => _result?.additionalUserInfo?.isNewUser ?? false;

  static String get username => _result?.additionalUserInfo?.username ?? '';

  static String _providerId = '';
  static String get providerId =>
      _result?.additionalUserInfo?.providerId ?? _providerId;

  static String _uid = '';
  static String get uid => _uid;

  static String _displayName = '';
  static String get displayName => _displayName;

  static String _photoUrl = '';
  static String get photoUrl => _photoUrl;

  static String _email = '';
  static String get email => _email;

  static String _phoneNumber = '';
  static String get phoneNumber => _phoneNumber;

  static bool _isEmailVerified = false;
  static bool get isEmailVerified => _isEmailVerified;

  static bool _isAnonymous = false;
  static bool get isAnonymous => _isAnonymous;

  static String _idToken = '';
  static String get idToken => _idToken;

  static String _accessToken = '';
  static String get accessToken => _accessToken;

  static IdTokenResult _idTokenResult;
  static IdTokenResult get idTokenResult => _idTokenResult;

  static DateTime get expirationTime =>
      _idTokenResult?.expirationTime ?? DateTime.now();

  static DateTime get authTime => _idTokenResult?.authTime ?? DateTime.now();

  static DateTime get issuedAtTime =>
      _idTokenResult?.issuedAtTime ?? DateTime.now();

  static String get signInProvider => _idTokenResult?.signInProvider ?? '';

  static Map<dynamic, dynamic> get claims => _idTokenResult?.claims ?? {};
}
