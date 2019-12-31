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
    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    show SignInOption;

import 'package:flutter_facebook_login/flutter_facebook_login.dart'
    show
        FacebookAccessToken,
        FacebookLogin,
        FacebookLoginResult,
        FacebookLoginStatus;

import 'package:flutter_twitter/flutter_twitter.dart';

typedef void FireBaseListener(FirebaseUser user);
typedef Future<FirebaseUser> FireBaseUser();
typedef void GoogleListener(GoogleSignInAccount event);

class Auth {
  static Auth _this;
  static FirebaseAuth _fireBaseAuth;
  static GoogleSignIn _googleSignIn;

  StreamSubscription<FirebaseUser> _firebaseListener;
  StreamSubscription<GoogleSignInAccount> _googleListener;

  GoogleSignIn _googleIn;
  FirebaseAuth _fbAuth;
  FacebookLogin _facebookLogin;
  TwitterLogin _twitterLogin;

  final List<String> _permissions = List();

  String _key;

  String _secret;

  Set<FireBaseListener> _fireBaseListeners = Set();
  bool _firebaseRunning = false;

  Set<GoogleListener> _googleListeners = Set();
  bool _googleRunning = false;

  List<Exception> _eventErrors = List();
  AuthResult _result;

  FirebaseUser _user;
  Exception _ex;

  String _idToken;

  String _accessToken;

  IdTokenResult _idTokenResult;

  String _uid = "";

  String _displayName = "";
  String _photoUrl = "";

  String _email = "";

  String _phoneNumber = "";

  bool _isEmailVerified = false;
  bool _isAnonymous = false;

  factory Auth.init({
    SignInOption signInOption = SignInOption.standard,
    List<String> scopes = const <String>[],
    String hostedDomain,
    void listen(GoogleSignInAccount account),
    void listener(FirebaseUser user),
    List<String> permissions,
    String key,
    String secret,
  }) {
    Auth auth;
    if (_this == null) {
      _this = Auth._init(
        signInOption: signInOption,
        scopes: scopes,
        hostedDomain: hostedDomain,
        listen: listen,
        listener: listener,
        permissions: permissions,
        key: key,
        secret: secret,
      );
      auth = _this;
    }

    /// Any subsequent instantiations are ignored.
    return auth;
  }

  Auth._init({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    void listen(GoogleSignInAccount account),
    void listener(FirebaseUser user),
    List<String> permissions,
    String key,
    String secret,
  }) {
    _initFireBase(listener: listener);

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

      if (permissions != null && permissions.isNotEmpty)
        _permissions.addAll(permissions);

      if (key != null && key.isNotEmpty) _key = key;

      if (secret != null && secret.isNotEmpty) _secret = secret;
    }
  }

  /// Facebook Login List of permissions.
  List<String> get permissions => _permissions;

  String get accessToken => _accessToken ?? "";

  DateTime get authTime => _idTokenResult?.authTime ?? DateTime.now();

  Map<dynamic, dynamic> get claims => _idTokenResult?.claims ?? {};

  String get displayName => _displayName;

  String get email => _email;

  bool get eventErrors => _eventErrors.isNotEmpty;

  @deprecated
  Exception get ex => _ex;

  DateTime get expirationTime =>
      _idTokenResult?.expirationTime ?? DateTime.now();

  FirebaseAuth get firebaseAuth => _fbAuth;

  GoogleSignIn get googleSignIn => _googleIn;

  /// The currently signed in account, or null if the user is signed out.
  GoogleSignInAccount get googleUser => _googleSignIn?.currentUser;

  String get idToken => _idToken ?? "";

  IdTokenResult get idTokenResult => _idTokenResult;

  bool get isAnonymous => _isAnonymous;

  bool get isEmailVerified => _isEmailVerified;

  DateTime get issuedAtTime => _idTokenResult?.issuedAtTime ?? DateTime.now();

  set listen(GoogleListener f) => addListen(f);

  set listener(FireBaseListener f) => addListener(f);

  String get message => _ex?.toString() ?? "";

  String get phoneNumber => _phoneNumber;

  String get photoUrl => _photoUrl;

  AuthResult get result => _result;

  String get signInProvider => _idTokenResult?.signInProvider ?? "";

  String get uid => _uid;

  FirebaseUser get user => _user;

  AdditionalUserInfo get userInfo => _result?.additionalUserInfo;

  String get username => _result?.additionalUserInfo?.username ?? "";

  bool get isNewUser => _result?.additionalUserInfo?.isNewUser ?? false;

  String get providerId =>
      _result?.additionalUserInfo?.providerId ?? user?.providerId ?? "";

  Future<bool> alreadyLoggedIn([GoogleSignInAccount googleUser]) async {
    FirebaseUser fireBaseUser;
    if (_fireBaseAuth != null) fireBaseUser = await _fireBaseAuth.currentUser();
    return _user != null &&
        fireBaseUser != null &&
        _user.uid == fireBaseUser.uid &&
        (googleUser == null ||
            googleUser.id == fireBaseUser?.providerData[1]?.uid);
  }

  /// Tries to create a new user account with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_INVALID_EMAIL` - If the email address is malformed.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  Future<bool> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    void listener(FirebaseUser user),
  }) async {
//    final loggedIn = await alreadyLoggedIn();
//    if (loggedIn) return loggedIn;

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

  /// Returns the currently signed-in [FirebaseUser] or [null] if there is none.
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

  /// Deletes the current user (also signs out the user).
  ///
  /// Errors:
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_INVALID_CREDENTIAL` - If the credential is malformed or has expired.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> delete() async {
    try {
      _user?.delete();
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<void> disconnect() async {
    await signOut();
    // Disconnect from Facebook
    _facebookLogin?.logOut();
    // Disconnect from Twitter
    _twitterLogin?.logOut();
    // Disconnect from Google
    if (_googleSignIn?.currentUser != null) _googleSignIn?.disconnect();
  }

  /// Important to call this function when terminating the you app.
  // However, doesn't not seem to be called?
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
    _facebookLogin = null;
    _twitterLogin = null;
  }

  /// Returns a list of sign-in methods that can be used to sign in a given
  /// user (identified by its main email address).
  ///
  /// This method is useful when you support multiple authentication mechanisms
  /// if you want to implement an email-first authentication flow.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the [email] address is malformed.
  ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address.
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

  /// Get the last error but clear it.
  Exception getError() {
    Exception e = _ex;
    _ex = null;
    return e;
  }

  List<Exception> getEventError() {
    var errors = _eventErrors;
    _eventErrors = null;
    return errors;
  }

  /// Obtains the id token result for the current user, forcing a [refresh] if desired.
  ///
  /// Useful when authenticating against your own backend. Use our server
  /// SDKs or follow the official documentation to securely verify the
  /// integrity and validity of this token.
  ///
  /// Completes with an error if the user is signed out.
  Future<IdTokenResult> getIdToken({bool refresh = false}) async {
    IdTokenResult result;
    try {
      result = await _user?.getIdToken(refresh: refresh);
    } catch (ex) {
      _setError(ex);
      result = null;
    }
    return result;
  }

  @deprecated
  bool fireBaseListener(FireBaseListener f) => addListener(f);

  /// Add a Firebase Listener
  bool addListener(FireBaseListener f) {
    bool add = f != null;
    if (add) add = _fireBaseListeners.add(f);
    return add;
  }

  @deprecated
  bool googleListener(GoogleListener f) => addListen(f);

  /// Add a Google listener
  bool addListen(GoogleListener f) {
    bool add = f != null;
    if (add) add = _googleListeners.add(f);
    return add;
  }

  /// FireBase Logged in.
  Future<bool> isLoggedIn() async {
    bool loggedIn = _user?.uid?.isNotEmpty ?? false;
    if (!loggedIn) {
      FirebaseUser user = await currentUser();
      loggedIn = user?.uid?.isNotEmpty ?? false;
    }
    return loggedIn;
  }

  /// Google Signed in.
  Future<bool> isSignedIn() async =>
      await isLoggedIn() && _googleSignIn?.currentUser != null;

  /// True if signed into Firebase
  bool signedInFirebase() => !signedInGoogle();

  /// True if signed into a Google account
  bool signedInGoogle() => googleUser != null;

  /// Associates a user account from a third-party identity provider with this
  /// user and returns additional identity provider data.
  ///
  /// This allows the user to sign in to this account in the future with
  /// the given account.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_INVALID_CREDENTIAL` - If the credential is malformed or has expired.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///   • `ERROR_CREDENTIAL_ALREADY_IN_USE` - If the account is already in use by a different account, e.g. with phone auth.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_PROVIDER_ALREADY_LINKED` - If the current user already has an account of this type linked.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that this type of account is not enabled.
  ///   • `ERROR_INVALID_ACTION_CODE` - If the action code in the link is malformed, expired, or has already been used.
  ///       This can only occur when using [EmailAuthProvider.getCredentialWithLink] to obtain the credential.
  Future<AuthResult> linkWithCredential(AuthCredential credential) async {
    try {
      _result = await _user?.linkWithCredential(credential);
    } catch (ex) {
      _setError(ex);
      _result = null;
    }
    return _result;
  }

  /// Renews the user’s authentication tokens by validating a fresh set of
  /// [credential]s supplied by the user and returns additional identity provider
  /// data.
  ///
  /// This is used to prevent or resolve `ERROR_REQUIRES_RECENT_LOGIN`
  /// response to operations that require a recent sign-in.
  ///
  /// If the user associated with the supplied credential is different from the
  /// current user, or if the validation of the supplied credentials fails; an
  /// error is returned and the current user remains signed in.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the [authToken] or [authTokenSecret] is malformed or has expired.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<AuthResult> reauthenticateWithCredential(
      AuthCredential credential) async {
    try {
      _result = await _user?.reauthenticateWithCredential(credential);
    } catch (ex) {
      _setError(ex);
      _result = null;
    }
    return _result;
  }

  /// Manually refreshes the data of the current user (for example,
  /// attached providers, display name, and so on).
  Future<void> reload() async {
    try {
      _user?.reload();
    } catch (ex) {
      _setError(ex);
    }
  }

  void removeListen(GoogleListener f) => _googleListeners.remove(f);

  void removeListener(FireBaseListener f) => _fireBaseListeners.remove(f);

  /// Initiates email verification for the user.
  Future<void> sendEmailVerification() async {
    try {
      _user?.sendEmailVerification();
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Triggers the Firebase Authentication backend to send a password-reset
  /// email to the given email address, which must correspond to an existing
  /// user of your app.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
  ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address.
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

  /// Sets the user-facing language code for auth operations that can be
  /// internationalized, such as [sendEmailVerification]. This language
  /// code should follow the conventions defined by the IETF in BCP47.
  Future<void> setLanguageCode(String language) async {
    try {
      await _fireBaseAuth.setLanguageCode(language).catchError((ex) {
        _setError(ex);
      });
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Asynchronously creates and becomes an anonymous user.
  ///
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead. If there is any other existing user signed in, that
  /// user will be signed out.
  ///
  /// **Important**: You must enable Anonymous accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Anonymous accounts are not enabled.
  Future<bool> signInAnonymously({
    void listener(FirebaseUser user),
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

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

  /// Attempt to sign in with one of the 'online' accounts:
  /// Google, Facebook and Twitter.
  Future<bool> signInSilently({
    String key,
    String secret,
    void listener(FirebaseUser user),
    void listen(GoogleSignInAccount user),
    bool suppressErrors = true,
  }) async {
    bool logIn = await alreadyLoggedIn();

    // Logged in but add the listener anyway.
    if (logIn) addListener(listener);

    if (!logIn) {
      /// Attempt to sign in with Twitter without user interaction
      logIn = await signInWithTwitterSilently(
        key: key,
        secret: secret,
        listener: listener,
      );
    }

    if (!logIn) {
      /// Attempt to sign in with Facebook without user interaction
      logIn = await signInWithFacebookSilently(
        permissions: permissions,
        listener: listener,
      );
    }
    
    if (!logIn) {
      /// Attempt to sign in with Google without user interaction
      logIn =
          await signInWithGoogleSilently(listen: listen, suppressErrors: true);
    }

    return logIn;
  }

  /// Attempts to sign in a previously authenticated user without interaction.
  ///
  /// Returned Future resolves to an instance of [GoogleSignInAccount] for a
  /// successful sign in or `null` if there is no previously authenticated user.
  /// Use [signInWithGoogle] method to trigger interactive sign in process.
  ///
  /// Authentication process is triggered only if there is no currently signed in
  /// user (that is when `currentUser == null`), otherwise this method returns
  /// a Future which resolves to the same user instance.
  ///
  /// Re-authentication can be triggered only after [signOut] or [disconnect].
  ///
  /// When [suppressErrors] is set to `false` and an error occurred during sign in
  /// returned Future completes with [PlatformException] whose `code` can be
  /// either [kSignInRequiredError] (when there is no authenticated user) or
  /// [kSignInFailedError] (when an unknown error occurred).
  Future<bool> signInWithGoogleSilently({
    void listen(GoogleSignInAccount user),
    bool suppressErrors = true,
  }) async {
    _initListen(listen: listen);

    // Attempt to get the currently authenticated user
    GoogleSignInAccount currentUser = _googleSignIn?.currentUser;

    if (currentUser == null) {
      try {
        // Attempt to sign in without user interaction
        currentUser = await _googleSignIn
            ?.signInSilently(suppressErrors: suppressErrors)
            ?.catchError((ex) {
          _setError(ex);
        })?.then((user) {
          return user;
        })?.catchError((ex) {
          _setError(ex);
        });
      } catch (ex) {
        _setError(ex);
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signInWithGoogleSilently();
        } else {
          currentUser = null;
        }
      }
    }
    return await _setFireBaseUserFromGoogle(currentUser);
  }

  /// Force the user to interactively sign in
  Future<bool> signInWithGoogle({
    void listen(GoogleSignInAccount event),
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
          return signInWithGoogle();
        } else {
          currentUser = null;
        }
      }
    }
    return await _setFireBaseUserFromGoogle(currentUser);
  }

  /// Log into Firebase using Google
  Future<bool> signInGoogle({
    void listen(GoogleSignInAccount user),
  }) async {
    /// Attempt to sign in without user interaction
    bool logIn =
        await signInWithGoogleSilently(listen: listen, suppressErrors: true);

    if (!logIn) {
      /// Force the user to interactively sign in
      logIn = await signInWithGoogle(listen: listen);
    }
    return logIn;
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// If the user doesn't have an account already, one will be created automatically.
  ///
  /// **Important**: You must enable the relevant accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the credential data is malformed or has expired.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL` - If there already exists an account with the email address asserted by Google.
  ///       Resolve this case by calling [fetchSignInMethodsForEmail] and then asking the user to sign in using one of them.
  ///       This error will only be thrown if the "One account per email address" setting is enabled in the Firebase console (recommended).
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Google accounts are not enabled.
  ///   • `ERROR_INVALID_ACTION_CODE` - If the action code in the link is malformed, expired, or has already been used.
  ///       This can only occur when using [EmailAuthProvider.getCredentialWithLink] to obtain the credential.
  Future<bool> signInWithCredential({
    @required AuthCredential credential,
    void listener(FirebaseUser user),
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

    final loggedIn = await alreadyLoggedIn();
    if (loggedIn) return loggedIn;

    _initFireBase(listener: listener);

    FirebaseUser user;
    try {
      user =
          await _fireBaseAuth.signInWithCredential(credential).then((result) {
        _result = result;
        final FirebaseUser usr = _result?.user;
        // Assign to the variable, user
        return usr;
      }).catchError((ex) {
        _setError(ex);
        _result = null;
      });
    } catch (ex) {
      _setError(ex);
      _result = null;
    }
    final bool signIn = await _setUserFromFireBase(user);
    return signIn;
  }

  /// Tries to sign in a user with a given Custom Token [token].
  ///
  /// A listener can also be provided.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Use this method after you retrieve a Firebase Auth Custom Token from your server.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CUSTOM_TOKEN` - The custom token format is incorrect.
  ///     Please check the documentation.
  ///   • `ERROR_CUSTOM_TOKEN_MISMATCH` - Invalid configuration.
  ///     Ensure your app's SHA1 is correct in the Firebase console.
  Future<bool> signInWithCustomToken({
    @required String token,
    void listener(FirebaseUser user),
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

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

  /// Tries to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// **Important**: You must enable Email & Password accounts in the Auth
  /// section of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
  ///   • `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
  ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  ///
  Future<bool> signInWithEmailAndPassword({
    @required String email,
    @required String password,
    void listener(FirebaseUser user),
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

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

  /// Silently Sign into Firebase with Facebook
  Future<bool> signInWithFacebookSilently({
    List<String> permissions,
    void listener(FirebaseUser user),
  }) =>
      signInWithFacebook(
        permissions: permissions,
        listener: listener,
        silently: true,
      );

  /// Sign into Firebase by logging into Facebook
  ///
  /// https://pub.dev/packages/flutter_facebook_login
  ///
  Future<bool> signInWithFacebook({
    List<String> permissions,
    void listener(FirebaseUser user),
    bool silently = false,
  }) async {
    try {
      _facebookLogin ??= FacebookLogin();
    } catch (ex) {
      _setError(ex);
    }

    if (_facebookLogin == null) return false;

    String token;
    bool loggedIn;
    FacebookAccessToken access;

    try {
      loggedIn = await _facebookLogin.isLoggedIn;
    } catch (ex) {
      loggedIn = false;
      _setError(ex);
    }

    if (loggedIn || silently) {
      try {
        access = await _facebookLogin.currentAccessToken;
      } catch (ex) {
        _setError(ex);
      }
      token = access?.token ?? "";
    } else {
      permissions ??= _permissions;
      if (permissions.isEmpty) permissions = ['email'];
      FacebookLoginResult result;
      try {
        result = await _facebookLogin.logIn(permissions);
        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            token = result?.accessToken?.token ?? "";
            break;
          case FacebookLoginStatus.cancelledByUser:
            token = "";
            break;
          case FacebookLoginStatus.error:
            token = "";
            _setError(Exception(result.errorMessage));
            break;
        }
      } catch (ex) {
        token = "";
        _setError(ex);
      }
    }

    bool signIn = false;

    if (token.isNotEmpty) {
      _accessToken = token;
      final AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: token);
      signIn = await signInWithCredential(
          credential: credential, listener: listener);
    }
    return signIn;
  }

  /// SignIn using Facebook.
  Future<bool> signInFacebook({
    List<String> permissions,
    void listener(FirebaseUser user),
  }) async {
    /// Attempt to sign in without user interaction
    bool logIn = await signInWithFacebookSilently(
      permissions: permissions,
      listener: listener,
    );

    if (!logIn) {
      /// Force the user to interactively sign in
      logIn = await signInWithFacebook(
        permissions: permissions,
        listener: listener,
      );
    }
    return logIn;
  }

  /// Silently Sign into Firebase with Twitter
  Future<bool> signInWithTwitterSilently({
    String key,
    String secret,
    void listener(FirebaseUser user),
  }) =>
      signInWithTwitter(
        key: key,
        secret: secret,
        listener: listener,
        silently: true,
        suppressAsserts: true,
      );

  /// Sign into Firebase by logging into Facebook
  ///
  ///  https://pub.dev/packages/flutter_twitter
  ///
  Future<bool> signInWithTwitter({
    String key,
    String secret,
    void listener(FirebaseUser user),
    bool silently = false,
    bool suppressAsserts = false,
  }) async {
    key ??= _key ?? "";
    secret ??= _secret ?? "";

    if (!suppressAsserts) {
      assert(
          key.isNotEmpty, "Must pass an key to signInWithTwitter() function!");
      assert(secret.isNotEmpty,
          "Must pass the secret to signInWithTwitter() function!");
    }

    if (key.isEmpty || secret.isEmpty) return false;

    String token;
    String tokenSecret = "";
    bool signIn = false;
    bool inSession;

    // Disconnect from Twitter first if logged in.
    await _twitterLogin?.logOut();
    _twitterLogin = null;

    try {
      _twitterLogin = TwitterLogin(consumerKey: key, consumerSecret: secret);
    } catch (ex) {
      _setError(ex);
    }

    if (_twitterLogin == null) return false;

    try {
      inSession = await _twitterLogin.isSessionActive;
    } catch (ex) {
      inSession = false;
      _setError(ex);
    }

    /// Don't bother logging in if the session is already active.
    if (inSession || silently) {
      TwitterSession session;
      try {
        session = await _twitterLogin.currentSession;
      } catch (ex) {
        session = null;
        _setError(ex);
      }
      token = session?.token ?? "";
      tokenSecret = session?.secret ?? "";
    } else {
      TwitterLoginResult result;
      try {
        result = await _twitterLogin.authorize();
        switch (result.status) {
          case TwitterLoginStatus.loggedIn:
            token = result.session.token;
            tokenSecret = result.session.secret;
            break;
          case TwitterLoginStatus.cancelledByUser:
            token = "";
            break;
          case TwitterLoginStatus.error:
            token = "";
            _setError(Exception(result.errorMessage));
            break;
        }
      } catch (ex) {
        token = "";
        _setError(ex);
      }
    }

    /// Sign into Firebase
    if (token.isNotEmpty) {
      _accessToken = token;
      AuthCredential credential = TwitterAuthProvider.getCredential(
          authToken: token, authTokenSecret: tokenSecret);
      signIn = await signInWithCredential(
          credential: credential, listener: listener);
    }
    return signIn;
  }

  /// SignIn using Twitter.
  Future<bool> signInTwitter({
    String key,
    String secret,
    void listener(FirebaseUser user),
  }) async {
    /// Attempt to sign in without user interaction
    bool logIn = await signInWithTwitterSilently(
      key: key,
      secret: secret,
      listener: listener,
    );

    if (!logIn) {
      /// Force the user to interactively sign in
      logIn = await signInWithTwitter(
        key: key,
        secret: secret,
        listener: listener,
      );
    }
    return logIn;
  }

  /// Signs out the current user and clears it from the disk cache.
  ///
  /// If successful, it signs the user out of the app and updates
  /// the [onAuthStateChanged] stream.
  Future<void> signOut() async {
    // Sign out with FireBase
    await _fireBaseAuth?.signOut();
    // Sign out with google
    // Does not disconnect however.
    _googleSignIn?.signOut();
  }

  /// Detaches the [provider] account from the current user.
  ///
  /// This will prevent the user from signing in to this account with those
  /// credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Use the `providerId` method of an auth provider for [provider].
  ///
  /// Errors:
  ///   • `ERROR_NO_SUCH_PROVIDER` - If the user does not have a Github Account linked to their account.
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  Future<void> unlinkFromProvider(String provider) async {
    try {
      _user?.unlinkFromProvider(provider);
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Updates the email address of the user.
  ///
  /// The original email address recipient will receive an email that allows
  /// them to revoke the email address change, in order to protect them
  /// from account hijacking.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the email address is malformed.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updateEmail(String email) async {
    try {
      _user?.updateEmail(email);
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Updates the password of the user.
  ///
  /// Anonymous users who update both their email and password will no
  /// longer be anonymous. They will be able to log in with these credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updatePassword(String password) async {
    try {
      _user?.updatePassword(password);
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Updates the phone number of the user.
  ///
  /// The new phone number credential corresponding to the phone number
  /// to be added to the Firebase account, if a phone number is already linked to the account.
  /// this new phone number will replace it.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  Future<void> updatePhoneNumberCredential(AuthCredential credential) async {
    try {
      _user?.updatePhoneNumberCredential(credential);
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Updates the user profile information.
  ///
  /// Errors:
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {
    try {
      _user?.updateProfile(userUpdateInfo);
    } catch (ex) {
      _setError(ex);
    }
  }

  /// Record errors for the event listeners.
  void _eventError(Object ex) {
    if (ex is! Exception) ex = Exception(ex.toString());
    _eventErrors.add(ex);
  }

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

    addListener(listener);
  }

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

  void _listFireBaseListeners(FirebaseUser user) async {
    if (_firebaseRunning) return;
    _firebaseRunning = true;
    await _setUserFromFireBase(user);
    for (var listener in _fireBaseListeners) {
      listener(user);
    }
    _firebaseRunning = false;
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

  void _setError(Object ex) {
    if (ex is! Exception) {
      _ex = Exception(ex.toString());
    } else {
      _ex = ex;
    }
  }

  Future<bool> _setFireBaseUserFromGoogle(
      GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication auth = await googleUser?.authentication;

    FirebaseUser user;
    AuthResult result;

    if (auth == null) {
      // Could be logged into Firebase
      user = await currentUser();
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

  Future<bool> _setUserFromFireBase(FirebaseUser user) async {
    _user = user;

    _idTokenResult = await user?.getIdToken();

    _idToken = _idTokenResult?.token ?? "";

    _accessToken = "";

    _isEmailVerified = user?.isEmailVerified ?? false;

    _isAnonymous = user?.isAnonymous ?? true;

    _uid = user?.uid ?? "";

    _displayName = user?.displayName ?? "";

    _photoUrl = user?.photoUrl ?? "";

    _email = user?.email ?? "";

    _phoneNumber = user?.phoneNumber ?? "";

    return _uid.isNotEmpty;
  }
}
