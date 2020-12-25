///
/// Copyright (C) 2018 Andrious Solutions
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
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
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart'
    show
        ActionCodeInfo,
        AdditionalUserInfo,
        UserCredential,
        AuthCredential,
        FirebaseAuth,
        FacebookAuthProvider,
        User,
        IdTokenResult,
        GoogleAuthProvider,
        TwitterAuthProvider,
        UserInfo;
import 'package:flutter/material.dart' show required;
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    show SignInOption;

export 'package:flutter_login_facebook/flutter_login_facebook.dart';

typedef FireBaseListener = void Function(User user);
typedef FirebaseUser = Future<User> Function();
typedef GoogleListener = void Function(GoogleSignInAccount event);

class Auth {
  factory Auth({
    SignInOption signInOption = SignInOption.standard,
    List<String> scopes = const <String>[],
    String hostedDomain,
    void Function(GoogleSignInAccount account) listen,
    void Function(User user) listener,
    List<FacebookPermission> permissions,
    String key,
    String secret,
  }) =>
      _this ??= Auth._(
        signInOption: signInOption,
        scopes: scopes,
        hostedDomain: hostedDomain,
        listen: listen,
        listener: listener,
        permissions: permissions,
        key: key,
        secret: secret,
      );

  Auth._({
    SignInOption signInOption,
    List<String> scopes,
    String hostedDomain,
    void Function(GoogleSignInAccount account) listen,
    void Function(User user) listener,
    List<FacebookPermission> permissions,
    String key,
    String secret,
  }) {
    _fireBaseListeners = <FireBaseListener>{};
    _firebaseRunning = false;

    _googleListeners = <GoogleListener>{};
    _googleRunning = false;

    _eventErrors = [];

    _initFireBase(listener: listener);

    if (_mobGoogleSignIn == null) {
      _mobGoogleSignIn = GoogleSignIn(
          signInOption: signInOption,
          scopes: scopes,
          hostedDomain: hostedDomain);
      // Store in an instance variable
      _googleIn = _mobGoogleSignIn;

      _initListen(
        listen: listen,
      );

      if (permissions != null && permissions.isNotEmpty) {
        _permissions.addAll(permissions);
      }

      if (key != null && key.isNotEmpty) {
        _key = key;
      }

      if (secret != null && secret.isNotEmpty) {
        _secret = secret;
      }
    }
  }

  static Auth _this;
  static FirebaseAuth _modAuth;
  static GoogleSignIn _mobGoogleSignIn;

  StreamSubscription<User> _firebaseListener;
  StreamSubscription<GoogleSignInAccount> _googleListener;

  GoogleSignIn _googleIn;
  FirebaseAuth _fbAuth;
  FacebookLogin _facebookLogin;
  TwitterLogin _twitterLogin;

  String _key;
  String _secret;

  Set<FireBaseListener> _fireBaseListeners;
  bool _firebaseRunning;

  Set<GoogleListener> _googleListeners;
  bool _googleRunning;

  List<Exception> _eventErrors;

  /// Facebook Login List of permissions.
  List<FacebookPermission> get permissions => _permissions;
  final List<FacebookPermission> _permissions = [];

  String get accessToken => _accessToken ?? '';
  String _accessToken = '';

  DateTime get authTime => _idTokenResult?.authTime ?? DateTime.now();

  Map<dynamic, dynamic> get claims => _idTokenResult?.claims ?? {};

  String get displayName => _displayName;
  String _displayName = '';

  String get email => _email;
  String _email = '';

  bool get eventErrors => _eventErrors.isNotEmpty;

  @Deprecated('Use getError() instead.')
  Exception get ex => _ex;
  Exception _ex;

  DateTime get expirationTime =>
      _idTokenResult?.expirationTime ?? DateTime.now();

//  @Deprecated('No access to Firebase Auth')
  FirebaseAuth get firebaseAuth => _fbAuth;

  GoogleSignIn get googleSignIn => _googleIn;

  /// The currently signed in account, or null if the user is signed out.
  GoogleSignInAccount get googleUser => _mobGoogleSignIn?.currentUser;

  String get idToken => _idToken ?? '';
  String _idToken;

  IdTokenResult get idTokenResult => _idTokenResult;
  IdTokenResult _idTokenResult;

  bool get isAnonymous => _isAnonymous;
  bool _isAnonymous = false;

  bool get isEmailVerified => _isEmailVerified;
  bool _isEmailVerified = false;

  DateTime get issuedAtTime => _idTokenResult?.issuedAtTime ?? DateTime.now();

  // ignore: avoid_setters_without_getters
  set listen(GoogleListener f) => addListen(f);

  // ignore: avoid_setters_without_getters
  set listener(FireBaseListener f) => addListener(f);

  String get message => _ex?.toString() ?? '';

  String get phoneNumber => _phoneNumber;
  String _phoneNumber = '';

  String get photoUrl => _photoUrl;
  String _photoUrl = '';

  UserCredential get result => _result;

  String get signInProvider => _idTokenResult?.signInProvider ?? '';

  String get uid => _uid;
  String _uid = '';

  User get user => _user;
  User _user;

  UserCredential _result;

  AdditionalUserInfo get userInfo => _result?.additionalUserInfo;

  String get username => _result?.additionalUserInfo?.username ?? '';

  bool get isNewUser => _result?.additionalUserInfo?.isNewUser ?? false;

  String get providerId => _result?.additionalUserInfo?.providerId ?? '';

  bool alreadyLoggedIn([GoogleSignInAccount googleUser]) {
    User fireBaseUser;
    if (_modAuth != null) {
      fireBaseUser = _modAuth.currentUser;
    }
    return _user != null &&
        fireBaseUser != null &&
        _user.uid == fireBaseUser.uid &&
        (googleUser == null ||
            googleUser.id == fireBaseUser?.providerData[1]?.uid);
  }

  /// Returns the currently signed-in [User] or null if there is none.
  User currentUser() {
    User user;
    try {
      user = _modAuth?.currentUser;
    } catch (ex) {
      setError(ex);
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
  Future<bool> delete() async {
    var delete = false;
    if (_user != null) {
      try {
        await _user.delete();
        delete = true;
      } catch (ex) {
        setError(ex);
      }
    }
    return delete;
  }

  /// Important to call this function when terminating the you app.
  // However, doesn't not seem to be called?
  Future<void> dispose() async {
    await signOut();
    _user = null;
    _modAuth = null;
    _mobGoogleSignIn = null;
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
      providers = await _modAuth?.fetchSignInMethodsForEmail(email);
    } catch (ex) {
      setError(ex);
      providers = null;
    }
    return providers;
  }

  bool get hasError => _ex != null;

  bool get inError => _ex != null;

  /// Get the last error but clear it.
  Exception getError() {
    final e = _ex;
    _ex = null;
    return e;
  }

  void setError(Object ex) {
    if (ex is! Exception) {
      _ex = Exception(ex.toString());
    } else {
      _ex = ex;
    }

    if (ex is PlatformException) {
      switch (ex.code) {
        case 'network_error':
          // The device's Internet is turned off.
          if (ex.message.contains('7:')) {
            _ex = Exception('Turn on your Wifi or Data.\r ${ex.toString()}');
          }
          break;
      }
    }
  }

  List<Exception> getEventError() {
    final errors = _eventErrors;
    _eventErrors = null;
    return errors;
  }

  /// Applies a verification code sent to the user by email or other out-of-band
  /// mechanism.
  ///
  /// A FirebaseAuthException may be thrown
  Future<void> applyActionCode(String code) {
    if (code == null || code.isEmpty) {
      return Future.value();
    }
    return _modAuth.applyActionCode(code);
  }

  /// Checks a verification code sent to the user by email or other out-of-band
  /// mechanism.
  ///
  /// Returns [ActionCodeInfo] about the code.
  ///
  /// A FirebaseAuthException may be thrown:
  Future<ActionCodeInfo> checkActionCode(String code) {
    if (code == null || code.isEmpty) {
      return Future.value();
    }
    return _modAuth.checkActionCode(code);
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
      result = await _user?.getIdTokenResult(refresh);
    } catch (ex) {
      setError(ex);
      result = null;
    }
    return result;
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  Stream<User> idTokenChanges() => _modAuth.idTokenChanges();

  /// Notifies about changes to any user updates.
  ///
  Stream<User> userChanges() => _modAuth.userChanges();

  /// Updates the current instance with the provided settings.
  ///
  Future<void> setSettings(
          {bool appVerificationDisabledForTesting, String userAccessGroup}) =>
      _modAuth.setSettings(
        appVerificationDisabledForTesting: appVerificationDisabledForTesting,
        userAccessGroup: userAccessGroup,
      );

  @Deprecated('Use addListener() instead.')
  bool fireBaseListener(FireBaseListener f) => addListener(f);

  /// Add a Firebase Listener
  bool addListener(FireBaseListener f) {
    var add = f != null;
    if (add) {
      add = _fireBaseListeners.add(f);
    }
    return add;
  }

  @Deprecated('Use add Listen() instead.')
  bool googleListener(GoogleListener f) => addListen(f);

  /// Add a Google listener
  bool addListen(GoogleListener f) {
    var add = f != null;
    if (add) {
      add = _googleListeners.add(f);
    }
    return add;
  }

  /// FireBase Logged in.
  bool isLoggedIn() {
    bool loggedIn;
    loggedIn = _user?.uid?.isNotEmpty ?? false;
    if (!loggedIn) {
      final user = currentUser();
      loggedIn = user?.uid?.isNotEmpty ?? false;
    }
    return loggedIn;
  }

  /// Google Signed in.
  bool isSignedIn() {
    bool isSignedIn;
    isSignedIn = isLoggedIn();
    if (!isSignedIn) {
      isSignedIn = _mobGoogleSignIn?.currentUser != null;
    }
    return isSignedIn;
  }

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
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    try {
      _result = await _user?.linkWithCredential(credential);
    } catch (ex) {
      setError(ex);
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
  ///   • `ERROR_INVALID_CREDENTIAL` - If the authToken or authTokenSecret is malformed or has expired.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<UserCredential> reauthenticateWithCredential(
      AuthCredential credential) async {
    try {
      _result = await _user?.reauthenticateWithCredential(credential);
    } catch (ex) {
      setError(ex);
      _result = null;
    }
    return _result;
  }

  /// Manually refreshes the data of the current user (for example,
  /// attached providers, display name, and so on).
  Future<void> reload() async {
    try {
      await _user?.reload();
    } catch (ex) {
      setError(ex);
    }
  }

  void removeListen(GoogleListener f) => _googleListeners.remove(f);

  void removeListener(FireBaseListener f) => _fireBaseListeners.remove(f);

  /// Initiates email verification for the user.
  Future<void> sendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
    } catch (ex) {
      setError(ex);
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
      await _modAuth?.sendPasswordResetEmail(email: email);
      reset = true;
    } catch (ex) {
      setError(ex);
      reset = false;
    }
    return reset;
  }

  /// Sets the user-facing language code for auth operations that can be
  /// internationalized, such as [sendEmailVerification]. This language
  /// code should follow the conventions defined by the IETF in BCP47.
  Future<void> setLanguageCode(String language) async {
    try {
      await _modAuth.setLanguageCode(language).catchError(setError);
    } catch (ex) {
      setError(ex);
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
    void Function(User user) listener,
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

    final loggedIn = alreadyLoggedIn();
    if (loggedIn) {
      return loggedIn;
    }
    await _initFireBase(listener: listener);

    User user;
    try {
      _result = await _modAuth.signInAnonymously();
      user = _result?.user;
    } catch (ex) {
      setError(ex);
      _result = null;
      user = null;
    }
    // The listener will call _setUserFromFireBase(user)
    // Must return null until 'awaits' are completed. -gp
    return user?.uid?.isNotEmpty ?? false;
  }

  /// Attempt to sign in with one of the 'online' accounts:
  /// Google, Facebook and Twitter.
  Future<bool> signInSilently({
    String key,
    String secret,
    void Function(User user) listener,
    void Function(GoogleSignInAccount user) listen,
    bool suppressErrors = true,
  }) async {
    var logIn = alreadyLoggedIn();

    // Logged in but add the listener anyway.
    if (logIn) {
      addListener(listener);
    }

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
      logIn = await signInWithGoogleSilently(listen: listen);
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
  /// returned Future completes with PlatformException whose `code` can be
  /// either kSignInRequiredError (when there is no authenticated user) or
  /// kSignInFailedError (when an unknown error occurred).
  Future<bool> signInWithGoogleSilently(
      {void Function(GoogleSignInAccount user) listen,
      bool suppressErrors = true}) async {
    await _initListen(listen: listen);

    // Attempt to get the currently authenticated user
    var currentUser = _mobGoogleSignIn?.currentUser;

    if (currentUser == null) {
      try {
        // Attempt to sign in without user interaction
        currentUser = await _mobGoogleSignIn
            ?.signInSilently(suppressErrors: suppressErrors)
            ?.catchError(setError)
            ?.then((user) {
          return user;
        })?.catchError(setError);
      } catch (ex) {
        setError(ex);
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signInWithGoogleSilently();
        } else {
          currentUser = null;
        }
      }
    }
    // Listener will call _setFireBaseUserFromGoogle(currentUser);
    return currentUser != null;
  }

  /// Force the user to interactively sign in
  Future<bool> signInWithGoogle({
    void Function(GoogleSignInAccount event) listen,
    bool popup,
  }) async {
    await _initListen(listen: listen);

    // Attempt to get the currently authenticated user
    var currentUser = _mobGoogleSignIn.currentUser;

    if (currentUser == null) {
      try {
        // Force the user to interactively sign in
        currentUser = await _mobGoogleSignIn.signIn();
      } catch (ex) {
        setError(ex);
        if (ex.toString().indexOf('INTERNAL') > 0) {
          // Simply run it again to make it work.
          return signInWithGoogle();
        } else {
          currentUser = null;
        }
      }
    }
    // Listenr will call _setFireBaseUserFromGoogle(currentUser);
    return currentUser != null;
  }

  /// Log into Firebase using Google
  Future<bool> signInGoogle({
    void Function(GoogleSignInAccount user) listen,
    bool firebaseUser = true,
  }) async {
    /// Attempt to sign in without user interaction
    var logIn = await signInWithGoogleSilently(listen: listen);

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
  /// the onAuthStateChanged stream.
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
    void Function(User user) listener,
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

    final loggedIn = alreadyLoggedIn();
    if (loggedIn) {
      return loggedIn;
    }

    await _initFireBase(listener: listener);

    User user;
    try {
      user = await _modAuth.signInWithCredential(credential).then((result) {
        _result = result;
        final usr = _result?.user;
        // Assign to the variable, user
        return usr;
      }).catchError((Object ex) {
        setError(ex);
        _result = null;
      });
    } catch (ex) {
      setError(ex);
      _result = null;
    }
    final signIn = await _setUserFromFireBase(user);
    return signIn;
  }

  /// Tries to sign in a user with a given Custom Token [token].
  ///
  /// A listener can also be provided.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the onAuthStateChanged stream.
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
    void Function(User user) listener,
  }) async {
    //
    final loggedIn = alreadyLoggedIn();
    if (loggedIn) {
      return loggedIn;
    }

    await _initFireBase(listener: listener);

    User user;
    try {
      user = await _modAuth.signInWithCustomToken(token).then((result) {
        _result = result;
        final usr = _result?.user;
        return usr;
      }).catchError((Object ex) {
        setError(ex);
        _result = null;
        user = null;
      });
    } catch (ex) {
      setError(ex);
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  /// Tries to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the onAuthStateChanged stream.
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
    void Function(User user) listener,
  }) async {
    // Logged in but add the listener anyway.
    addListener(listener);

    final loggedIn = alreadyLoggedIn();
    if (loggedIn) {
      return loggedIn;
    }

    await _initFireBase(listener: listener);

    User user;
    try {
      user = await _modAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((result) {
        _result = result;
        final usr = _result?.user;
        return usr;
      }).catchError((Object ex) {
        setError(ex);
        _result = null;
        user = null;
      });
    } catch (ex) {
      setError(ex);
      _result = null;
      user = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  /// Tries to create a new user account with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the onAuthStateChanged stream.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_INVALID_EMAIL` - If the email address is malformed.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  Future<bool> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    void Function(User user) listener,
  }) async {
//    final loggedIn = await alreadyLoggedIn();
//    if (loggedIn) return loggedIn;

    await _initFireBase(listener: listener);

    User user;
    try {
      user = await _modAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) {
        _result = result;
        final usr = _result.user;
        return usr;
      });
    } catch (ex) {
      setError(ex);
      user = null;
      _result = null;
    }
    return user?.uid?.isNotEmpty ?? false;
  }

  /// Completes the password reset process, given a confirmation code and new
  /// password.
  ///
  ///  - Thrown if the new password is not strong enough.
  Future<void> confirmPasswordReset({String code, String newPassword}) =>
      confirmPasswordReset(code: code, newPassword: newPassword);

  /// Returns a UserCredential from the redirect-based sign-in flow.
  ///
  /// If sign-in succeeded, returns the signed in user. If sign-in was
  /// unsuccessful, fails with an error. If no redirect operation was called,
  /// returns a [UserCredential] with a null User.
  ///
  /// This method is only support on web platforms.
  Future<UserCredential> getRedirectResult() => _modAuth.getRedirectResult();

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink) {
    if (emailLink == null || emailLink.isEmpty) {
      return false;
    }
    return _modAuth.isSignInWithEmailLink(emailLink);
  }

  /// Silently Sign into Firebase with Facebook
  Future<bool> signInWithFacebookSilently({
    List<FacebookPermission> permissions,
    void Function(User user) listener,
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
    List<FacebookPermission> permissions,
    void Function(User user) listener,
    bool silently = false,
  }) async {
    try {
      _facebookLogin ??= FacebookLogin();
    } catch (ex) {
      setError(ex);
    }

    if (_facebookLogin == null) {
      return false;
    }

    String token;
    bool loggedIn;
    FacebookAccessToken access;

    try {
      loggedIn = await _facebookLogin.isLoggedIn;
    } catch (ex) {
      loggedIn = false;
      setError(ex);
    }

    if (loggedIn || silently) {
      try {
        access = await _facebookLogin.accessToken;
      } catch (ex) {
        setError(ex);
      }
      token = access?.token ?? '';
    } else {
      permissions ??= _permissions;

      if (permissions.isEmpty) {
        permissions = [FacebookPermission.email];
      }

      FacebookLoginResult result;

      try {
        result = await _facebookLogin.logIn(permissions: permissions);

        if (result.status == FacebookLoginStatus.success) {
          //
          token = result?.accessToken?.token ?? '';
        } else if (result.status == FacebookLoginStatus.cancel) {
          //
          token = '';
        } else if (result.status == FacebookLoginStatus.error) {
          //
          token = '';
          setError(Exception(result.error.developerMessage));
        }
      } catch (ex) {
        token = '';

        setError(ex);
      }
    }

    var signIn = false;

    if (token.isNotEmpty) {
      // No need this is done in signInWithCredential
      _accessToken = token;
      final AuthCredential credential = FacebookAuthProvider.credential(token);
      signIn = await signInWithCredential(
          credential: credential, listener: listener);
    }
    return signIn;
  }

  /// SignIn using Facebook.
  Future<bool> signInFacebook({
    List<FacebookPermission> permissions,
    void Function(User user) listener,
  }) async {
    /// Attempt to sign in without user interaction
    var logIn = await signInWithFacebookSilently(
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
    void Function(User user) listener,
  }) =>
      signInWithTwitter(
        key: key,
        secret: secret,
        listener: listener,
        silently: true,
        suppressAsserts: true,
      );

  /// Sign into Firebase by logging into Twitter
  ///
  ///  https://pub.dev/packages/flutter_twitter
  ///
  Future<bool> signInWithTwitter({
    String key,
    String secret,
    void Function(User user) listener,
    bool silently = false,
    bool suppressAsserts = false,
  }) async {
    key ??= _key ?? '';
    secret ??= _secret ?? '';

    if (!suppressAsserts) {
      assert(
          key.isNotEmpty, 'Must pass an key to signInWithTwitter() function!');
      assert(secret.isNotEmpty,
          'Must pass the secret to signInWithTwitter() function!');
    }

    if (key.isEmpty || secret.isEmpty) {
      return false;
    }

    String token;
    var tokenSecret = '';
    var signIn = false;
    bool inSession;

    // Disconnect from Twitter first if logged in.
    await _twitterLogin?.logOut();
    _twitterLogin = null;

    try {
      _twitterLogin = TwitterLogin(consumerKey: key, consumerSecret: secret);
    } catch (ex) {
      setError(ex);
    }

    if (_twitterLogin == null) {
      return false;
    }

    try {
      inSession = await _twitterLogin.isSessionActive;
    } catch (ex) {
      inSession = false;
      setError(ex);
    }

    /// Don't bother logging in if the session is already active.
    if (inSession || silently) {
      TwitterSession session;
      try {
        session = await _twitterLogin.currentSession;
      } catch (ex) {
        session = null;
        setError(ex);
      }
      token = session?.token ?? '';
      tokenSecret = session?.secret ?? '';
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
            token = '';
            break;
          case TwitterLoginStatus.error:
            token = '';
            setError(Exception(result.errorMessage));
            break;
        }
      } catch (ex) {
        token = '';
        setError(ex);
      }
    }

    /// Sign into Firebase
    if (token.isNotEmpty) {
      _accessToken = token;
      final AuthCredential credential = TwitterAuthProvider.credential(
          accessToken: token, secret: tokenSecret);
      signIn = await signInWithCredential(
          credential: credential, listener: listener);
    }
    return signIn;
  }

  /// SignIn using Twitter.
  Future<bool> signInTwitter({
    String key,
    String secret,
    void Function(User user) listener,
  }) async {
    /// Attempt to sign in without user interaction
    var logIn = await signInWithTwitterSilently(
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
  /// the onAuthStateChanged stream.
  Future<void> signOut() async {
    await _setUserFromFireBase(null);
    // Sign out with FireBase
    await _modAuth?.signOut();
    // Sign out with google
    // Does not disconnect however.
    await _mobGoogleSignIn?.signOut();
  }

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<void> disconnect() async {
    await signOut();
    // Disconnect from Facebook
    await _facebookLogin?.logOut();
    // Disconnect from Twitter
    await _twitterLogin?.logOut();
    // Disconnect from Google
    if (_mobGoogleSignIn?.currentUser != null) {
      await _mobGoogleSignIn?.disconnect();
    }
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
  @Deprecated('unlinkFromProvider() no longer functional.')
  Future<void> unlinkFromProvider(String provider) async {}

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
      await _user?.updateEmail(email);
    } catch (ex) {
      setError(ex);
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
      await _user?.updatePassword(password);
    } catch (ex) {
      setError(ex);
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
  @Deprecated('Use updatePhoneNumber() instead.')
  Future<void> updatePhoneNumberCredential(AuthCredential credential) =>
      updatePhoneNumber(credential);

  Future<void> updatePhoneNumber(AuthCredential credential) async {
    try {
      await _user?.updatePhoneNumber(credential);
    } catch (ex) {
      setError(ex);
    }
  }

  /// Updates the user profile information.
  ///
  /// Errors:
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> updateProfile(UserInfo userUpdateInfo) async {
    try {
      await _user?.updateProfile(
          displayName: userUpdateInfo.displayName,
          photoURL: userUpdateInfo.photoURL);
    } catch (ex) {
      setError(ex);
    }
  }

  /// Record errors for the event listeners.
  void _eventError(Object ex) {
    if (ex is! Exception) {
      ex = Exception(ex.toString());
    }
    _eventErrors.add(ex);
  }

  Future<void> _initFireBase({
    void Function(User user) listener,
    Function onError,
    void Function() onDone,
    bool cancelOnError = false,
  }) async {
    // Clear any errors first.
    getError();
    getEventError();

    if (_modAuth == null) {
      await Firebase.initializeApp();
      _modAuth = FirebaseAuth.instance;
      _firebaseListener = _modAuth.authStateChanges().listen(
          _listFireBaseListeners,
          onError: onError ?? _eventError,
          onDone: onDone,
          cancelOnError: cancelOnError);
      // Store in an instance variable
      _fbAuth = _modAuth;
    }

    addListener(listener);
  }

  Future<void> _initListen({
    void Function(GoogleSignInAccount account) listen,
    Function onError,
    void Function() onDone,
    bool cancelOnError = false,
  }) async {
    // Clear any errors first.
    getError();
    getEventError();

    if (listen != null) {
      _googleListeners.add(listen);
    }

    _googleListener ??= _mobGoogleSignIn?.onCurrentUserChanged?.listen(
        _listGoogleListeners,
        onError: onError ?? _eventError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  Future<void> _listFireBaseListeners(User user) async {
    if (_firebaseRunning) {
      return;
    }
    _firebaseRunning = true;
    await _setUserFromFireBase(user);
    if (_fireBaseListeners != null) {
      // Odd error at times. gp
      for (final listener in _fireBaseListeners) {
        listener(user);
      }
    }
    _firebaseRunning = false;
  }

  /// async so you'll come back if there's a setState() called in the listener.
  Future<void> _listGoogleListeners(GoogleSignInAccount account) async {
    if (_googleRunning) {
      return;
    }
    _googleRunning = true;
    await _setFireBaseUserFromGoogle(account);
    for (final listener in _googleListeners) {
      listener(account);
    }
    _googleRunning = false;
  }

  // firebaseUser = true will check if logged in Firebase
  Future<bool> _setFireBaseUserFromGoogle(
      GoogleSignInAccount googleUser) async {
    final auth = await googleUser?.authentication;

    User user;
    UserCredential result;

    if (auth != null) {
      try {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        result = await _modAuth.signInWithCredential(credential);
        user = result?.user;
      } catch (ex) {
        setError(ex);
        result = null;
        user = null;
      }
    }

    final set = await _setUserFromFireBase(user);

    _result = result;

    _idToken = auth?.idToken ?? '';

    _accessToken = auth?.accessToken ?? '';

    return set;
  }

  Future<bool> _setUserFromFireBase(User user) async {
    _user = user;

    _isEmailVerified = _user?.emailVerified ?? false;

    _isAnonymous = _user?.isAnonymous ?? true;

    _uid = _user?.uid ?? ' ';

    _displayName = _user?.displayName ?? '';

    _photoUrl = _user?.photoURL ?? '';

    _email = _user?.email ?? '';

    _phoneNumber = _user?.phoneNumber ?? '';

    try {
      // Perform this 'await' near the end to assign the rest.
      _idTokenResult = await _user?.getIdTokenResult();
    } catch (ex) {
      setError(ex);
    }

    _idToken = _idTokenResult?.token ?? '';

    return _uid.isNotEmpty;
  }
}
