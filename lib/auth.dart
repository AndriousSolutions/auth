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
        TwitterAuthProvider;
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
  factory Auth.init({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    void listen(GoogleSignInAccount account),
    void listener(FirebaseUser user),
  }) {
    Auth auth;
    if (_this == null) {
      _this = Auth._init(
          signInOption: signInOption,
          scopes: scopes,
          hostedDomain: hostedDomain,
          listen: listen,
          listener: listener);
      auth = _this;
    }

    /// Any subsequent instantiations are ignored.
    return auth;
  }
  static Auth _this;
  static FirebaseAuth _fireBaseAuth;
  static GoogleSignIn _googleSignIn;

  /// Important to call this function when terminating the you app.
  void dispose() async {
    await signOut();
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

  StreamSubscription<FirebaseUser> _firebaseListener;
  StreamSubscription<GoogleSignInAccount> _googleListener;

  Auth._init({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    void listen(GoogleSignInAccount account),
    void listener(FirebaseUser user),
  }) {
    _initFireBase(
      listener: listener,
    );

    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn(
          signInOption: signInOption,
          scopes: scopes,
          hostedDomain: hostedDomain);
      // Store in an instance variable
      _googleIn = _googleSignIn;

      _initListen(
        listen: listen,
      );
    }
  }
  GoogleSignIn _googleIn;
  GoogleSignIn get googleSignIn => _googleIn;

  _initFireBase({
    void listener(FirebaseUser user),
    Function onError,
    void onDone(),
    bool cancelOnError = false,
  }) {
    // Clear any errors first.
    getError();
    getEventError();

    if (_fireBaseAuth == null) {
      _fireBaseAuth = FirebaseAuth.instance;
      _firebaseListener = _fireBaseAuth.onAuthStateChanged.listen(
          _listFireBaseListeners,
          onError: _eventError,
          onDone: onDone,
          cancelOnError: cancelOnError);
      // Store in an instance variable
      _fbAuth = _fireBaseAuth;
    }

    if (listener != null) {
      _fireBaseListeners.add(listener);
    }
  }

  FirebaseAuth _fbAuth;
  FirebaseAuth get firebaseAuth => _fbAuth;

  Set<FireBaseListener> _fireBaseListeners = Set();
  bool _firebaseRunning = false;

  void _listFireBaseListeners(FirebaseUser user) async {
    if (_firebaseRunning) return;
    _firebaseRunning = true;
    await _setUserFromFireBase(user);
    for (var listener in _fireBaseListeners) {
      listener(user);
    }
    _firebaseRunning = false;
  }

  fireBaseListener(FireBaseListener f) => _fireBaseListeners.add(f);

  removeListener(FireBaseListener f) => _fireBaseListeners.remove(f);

  Set<GoogleListener> _googleListeners = Set();
  bool _googleRunning = false;

  void _initListen({
    void listen(GoogleSignInAccount account),
    Function onError,
    void onDone(),
    bool cancelOnError = false,
  }) async {
    // Clear any errors first.
    getError();
    getEventError();

    if (listen != null) _googleListeners.add(listen);

    if (_googleListener == null) {
      _googleListener = _googleSignIn?.onCurrentUserChanged?.listen(
          _listGoogleListeners,
          onError: _eventError,
          onDone: onDone,
          cancelOnError: cancelOnError);
    }
  }

  /// async so you'll come back if there's a setState() called in the listener.
  void _listGoogleListeners(GoogleSignInAccount account) async {
    if (_googleRunning) return;
    _googleRunning = true;
    await _setFireBaseUserFromGoogle(account);
    for (var listener in _googleListeners) {
      listener(account);
    }
    _googleRunning = false;
  }

  List<Exception> _eventErrors = List();
  List<Exception> getEventError() {
    var errors = _eventErrors;
    _eventErrors = null;
    return errors;
  }

  bool get eventErrors => _eventErrors.isNotEmpty;

  /// Record errors for the event listeners.
  void _eventError(Object ex) {
    if (ex is! Exception) ex = Exception(ex.toString());
    _eventErrors.add(ex);
  }

  void googleListener(GoogleListener f) => _googleListeners.add(f);

  void removeListen(GoogleListener f) => _googleListeners.remove(f);

  Future<bool> alreadyLoggedIn([GoogleSignInAccount googleUser]) async {
    FirebaseUser fireBaseUser;
    if (_fireBaseAuth != null) fireBaseUser = await _fireBaseAuth.currentUser();
    return _user != null &&
        fireBaseUser != null &&
        _user.uid == fireBaseUser.uid &&
        (googleUser == null ||
            googleUser.id == fireBaseUser?.providerData[1]?.uid);
  }

  /// Firebase Login.
  Future<bool> signInAnonymously({
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
      _setError(ex);
      _result = null;
      user = null;
    }
    // Must return null until 'awaits' are completed. -gp
    return user?.uid?.isNotEmpty ?? false;
  }

  Future<bool> createUserWithEmailAndPassword({
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
      _setError(ex);
      user = null;
      _result = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  Future<List<String>> fetchSignInMethodsForEmail({
    @required String email,
  }) async {
    List<String> providers;

    try {
      providers = await _fireBaseAuth?.fetchSignInMethodsForEmail(email: email);
    } catch (ex) {
      _setError(ex);
      providers = null;
    }
    return providers;
  }

  Future<bool> sendPasswordResetEmail({
    @required String email,
  }) async {
    bool reset;
    try {
      await _fireBaseAuth?.sendPasswordResetEmail(email: email);
      reset = true;
    } catch (ex) {
      _setError(ex);
      reset = false;
    }
    return reset;
  }

  Future<bool> signInWithEmailAndPassword({
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
        _setError(ex);
        _result = null;
        user = null;
      });
    } catch (ex) {
      _setError(ex);
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  Future<bool> signInWithCredential({
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
        _setError(ex);
        _result = null;
        user = null;
      });
    } catch (ex) {
      _setError(ex);
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  Future<bool> signInWithCustomToken({
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
      }).catchError((ex) {
        _setError(ex);
        _result = null;
        user = null;
      });
    } catch (ex) {
      _setError(ex);
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  Future<void> setLanguageCode(String language) async {
    try {
      await _fireBaseAuth.setLanguageCode(language).catchError((ex) {
        _setError(ex);
      });
    } catch (ex) {
      _setError(ex);
    }
  }

  Future<bool> _setUserFromFireBase(FirebaseUser user) async {
    _user = user;

    _idTokenResult = await user?.getIdToken();

    _idToken = _idTokenResult?.token ?? "";

    _accessToken = "";

//    return user?.uid?.isNotEmpty ?? false;
//  }

    _isEmailVerified = user?.isEmailVerified ?? false;

    _isAnonymous = user?.isAnonymous ?? true;

    _uid = user?.uid ?? "";

    _displayName = user?.displayName ?? "";

    _photoUrl = user?.photoUrl ?? "";

    _email = user?.email ?? "";

    _phoneNumber = user?.phoneNumber ?? "";

    return _uid.isNotEmpty;
  }

  /// Log into Firebase using Google
  Future<bool> signInGoogle({
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
  Future<bool> signInSilently({
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
          _setError(ex);
        }).then((user) {
          return user;
        }).catchError((ex) {
          _setError(ex);
        });
      } catch (ex) {
        _setError(ex);
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signInSilently();
        } else {
          currentUser = null;
        }
      }
    }
    return await _setFireBaseUserFromGoogle(currentUser);
  }

  /// Force the user to interactively sign in
  Future<bool> signIn({
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
        _setError(ex);
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signIn();
        } else {
          currentUser = null;
        }
      }
    }
    return await _setFireBaseUserFromGoogle(currentUser);
  }

  Future<bool> _setFireBaseUserFromGoogle(
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
        _setError(ex);
        result = null;
        user = null;
      }
    }

    bool set = await _setUserFromFireBase(user);

    _result = result;

    _idToken = auth?.idToken ?? "";

    _accessToken = auth?.accessToken ?? "";

    return set;
  }

  Future<bool> signInWithFacebook(
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

  Future<bool> signInWithTwitter(
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

  Future<GoogleSignInAccount> disconnect() async {
    await signOut();
    // Disconnect from Google
    return _googleSignIn?.disconnect();
  }

  Future<void> signOut() async {
    // Sign out with FireBase
    await _fireBaseAuth?.signOut();
    // Sign out with google
    // Does not disconnect however.
    await _googleSignIn?.signOut();
  }

  /// Google Signed in.
  Future<bool> isSignedIn() async =>
      await isLoggedIn() && _googleSignIn?.currentUser != null;

  /// FireBase Logged in.
  Future<bool> isLoggedIn() async {
    bool loggedIn = _user?.uid?.isNotEmpty ?? false;
    if (!loggedIn) {
      FirebaseUser user = await currentUser();
      loggedIn = user?.uid?.isNotEmpty ?? false;
    }
    return loggedIn;
  }

  Future<FirebaseUser> currentUser() async {
    FirebaseUser user;
    try {
      user = await _fireBaseAuth?.currentUser();
    } catch (ex) {
      _setError(ex);
      user = null;
    }
    return user;
  }

  void _setError(Object ex) {
    if (ex is! Exception) {
      _ex = Exception(ex.toString());
    } else {
      _ex = ex;
    }
  }

  AuthResult _result;
  AuthResult get result => _result;

  /// The currently signed in account, or null if the user is signed out.
  GoogleSignInAccount get googleUser => _googleSignIn?.currentUser;

  /// True if signed into a Google account
  bool signedInGoogle() => googleUser != null;

  /// True if signed into Firebase
  bool signedInFirebase() => !signedInGoogle();

  FirebaseUser get user => _user;
  FirebaseUser _user;

  Exception _ex;
  @deprecated
  Exception get ex => _ex;
  String get message => _ex?.toString() ?? "";

  /// Get the last error but clear it.
  Exception getError() {
    Exception e = _ex;
    _ex = null;
    return e;
  }

  AdditionalUserInfo get userInfo => _result?.additionalUserInfo;

  bool get isNewUser => _result?.additionalUserInfo?.isNewUser ?? false;

  String get username => _result?.additionalUserInfo?.username ?? "";

  String _idToken;
  String get idToken => _idToken ?? "";

  String _accessToken;
  String get accessToken => _accessToken ?? "";

  IdTokenResult _idTokenResult;
  IdTokenResult get idTokenResult => _idTokenResult;

  String get providerId =>
      _result?.additionalUserInfo?.providerId ?? user?.providerId ?? "";

  String _uid = "";
  String get uid => _uid;

  String _displayName = "";
  String get displayName => _displayName;

  String _photoUrl = "";
  String get photoUrl => _photoUrl;

  String _email = "";
  String get email => _email;

  String _phoneNumber = "";
  String get phoneNumber => _phoneNumber;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  bool _isAnonymous = false;
  bool get isAnonymous => _isAnonymous;

  DateTime get expirationTime =>
      _idTokenResult?.expirationTime ?? DateTime.now();

  DateTime get authTime => _idTokenResult?.authTime ?? DateTime.now();

  DateTime get issuedAtTime => _idTokenResult?.issuedAtTime ?? DateTime.now();

  String get signInProvider => _idTokenResult?.signInProvider ?? "";

  Map<dynamic, dynamic> get claims => _idTokenResult?.claims ?? {};
}
