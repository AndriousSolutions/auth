/////
///// Copyright (C) 2018 Andrious Solutions
/////
///// Licensed under the Apache License, Version 2.0 (the "License");
///// you may not use this file except in compliance with the License.
///// You may obtain a copy of the License at
/////
/////    http://www.apache.org/licenses/LICENSE-2.0
/////
///// Unless required by applicable law or agreed to in writing, software
///// distributed under the License is distributed on an "AS IS" BASIS,
///// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///// See the License for the specific language governing permissions and
///// limitations under the License.
/////
/////           Created  10 May 2018
/////
///// Github: https://github.com/AndriousSolutions/auth
/////
//library auth;
//
//import 'dart:async' show Future, StreamSubscription;
//
//import 'package:flutter/material.dart' show required;
//
//import 'package:firebase/firebase.dart' as w;
//
//import 'package:firebase_auth/firebase_auth.dart' show AuthResult, FirebaseUser;
//
//import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
//
//class Auth {
//  factory Auth.init({
//    String email = "",
//    String password,
//    Map<String, dynamic> customOAuthParameters,
//    String token,
//    String accessToken = "",
//    String secret,
//    String phoneNumber = "",
//    w.EmailAuthProvider emailAuth,
//    w.FacebookAuthProvider facebookAuth,
//    w.GithubAuthProvider githubAuth,
//    w.GoogleAuthProvider googleAuth,
//    w.OAuthProvider oAuth,
//    w.TwitterAuthProvider twitterAuth,
//    w.PhoneAuthProvider phoneAuth,
//    List<String> scopes = const <String>[],
//    String hostedDomain,
//    void listener(w.User user),
//    Function onError,
//    void onDone(),
//    bool cancelOnError = false,
//    List<String> permissions,
//    String key,
//    String name,
//  }) {
//    // Already been instantiated.
//    if (_this != null) return _this;
//
//    _email = email;
//    _password = password;
//    _scopes.addAll(scopes);
//    _customOAuthParameters = customOAuthParameters;
//    _token = token;
//    _accessToken = accessToken;
//    _secret = secret;
//    _phoneNumber = phoneNumber;
//    //Providers
////    _emailAuth = emailAuth;
//    _facebookAuth = facebookAuth;
//    _githubAuth = githubAuth;
//    _googleAuth = googleAuth;
//    _oAuth = oAuth;
//    _twitterAuth = twitterAuth;
//    _phoneAuth = phoneAuth;
//    // init any listener
//    _this = Auth._init(name, listener, onError, onDone, cancelOnError);
//    return _this;
//  }
//  Auth._init(
//    String name,
//    void listener(w.User user),
//    Function onError,
//    void onDone(),
//    bool cancelOnError,
//  ) {
//    _app = app(name);
//    _auth = w.auth(_app);
//    onError ??= _eventError;
//    _authListener = _auth.onAuthStateChanged.listen(_listListeners,
//        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
//    addListener(listener);
//  }
//  static Auth _this;
//  static w.Auth _auth;
//  static w.UserCredential _userCredential;
//  static w.IdTokenResult _idTokenResult;
//
//  static w.EmailAuthProvider _emailAuth;
//  static w.FacebookAuthProvider _facebookAuth;
//  static w.GithubAuthProvider _githubAuth;
//  static w.GoogleAuthProvider _googleAuth;
//  static w.OAuthProvider _oAuth;
//  static w.TwitterAuthProvider _twitterAuth;
//  static w.PhoneAuthProvider _phoneAuth;
//
//  static String _email;
//  static String _password;
//  static Map<String, dynamic> _customOAuthParameters;
//  static String _token;
//  static String _accessToken;
//  static String _secret;
//  static String _phoneNumber;
//
//  static final Set<String> _scopes = Set();
//
//  //EmailAuth
//  //String email, String password
//  //
//  //FacebookAuthProvider
//  //GithubAuthProvider
//  //GoogleAuthProvider
//  //OAuthProvider
//  //String scope
//  //
//  //FacebookAuthProvider
//  //GithubAuthProvider
//  //GoogleAuthProvider
//  //OAuthProvider
//  //TwitterAuthProvider
//  // Map<String, dynamic> customOAuthParameters
//  //
//  //GithubAuthProvider
//  //GoogleAuthProvider
//  //OAuthProvider
//  //TwitterAuthProvider
//  //String token
//  //
//  //GoogleAuthProvider
//  //OAuthProvider
//  //String accessToken
//  //
//  //TwitterAuthProvider
//  //String secret
//
//  StreamSubscription<w.User> _authListener;
//  Set<void Function(w.User user)> _listeners = Set();
//
//  bool _firebaseRunning = false;
//
//  void _listListeners(w.User user) async {
//    if (_firebaseRunning) return;
//    _firebaseRunning = true;
//    // Ensure the User Credential is null
//    if (user = null) _userCredential = null;
//    await _setUserFromWebUser(user);
//    for (var listener in _listeners) {
//      listener(user);
//    }
//    _firebaseRunning = false;
//  }
//
//  List<Exception> _eventErrors = List();
//
//  /// Record errors for the event listeners.
//  void _eventError(Object ex) {
//    if (ex is! Exception) ex = Exception(ex.toString());
//    _eventErrors.add(ex);
//  }
//
//  List<Exception> getEventError() {
//    var errors = _eventErrors;
//    _eventErrors = null;
//    return errors;
//  }
//
//  /// Add a Listener
//  bool addListener(void Function(w.User user) f) {
//    bool add = f != null;
//    if (add) add = _listeners.add(f);
//    return add;
//  }
//
//  /// Add a Listener
//  set listener(void Function(w.User user) f) => addListener(f);
//
//  /// Remove a Listener
//  void removeListener(void Function(w.User user) f) => _listeners.remove(f);
//
//  static w.App _app;
//  w.App get firbaseApp => _app;
//
//  w.User _user;
//  w.User get user => _user;
//
//  String _idToken = "";
//  String get idToken => _idToken;
//
//  String get accessToken => _accessToken;
//
//  String _uid = "";
//  String get uid => _uid;
//
//  String _displayName = "";
//  String get displayName => _displayName;
//
//  String _photoUrl = "";
//  String get photoUrl => _photoUrl;
//
//  String get email => _email;
//
//  String get phoneNumber => _phoneNumber;
//
//  bool _isEmailVerified = false;
//  bool get isEmailVerified => _isEmailVerified;
//
//  String _providerId;
//  String get providerId =>
//      _providerId ?? _userCredential?.additionalUserInfo?.providerId ?? "";
//
//  bool _isAnonymous = false;
//  bool get isAnonymous => _isAnonymous;
//
//  DateTime get authTime => _idTokenResult?.authTime ?? DateTime.now();
//
//  Map<dynamic, dynamic> get claims => _idTokenResult?.claims ?? {};
//
//  w.IdTokenResult get idTokenResult => _idTokenResult;
//
//  DateTime get expirationTime =>
//      _idTokenResult?.expirationTime ?? DateTime.now();
//
//  DateTime get issuedAtTime => _idTokenResult?.issuedAtTime ?? DateTime.now();
//
//  String get signInProvider => _idTokenResult?.signInProvider ?? "";
//
//  w.AdditionalUserInfo get userInfo => _userCredential?.additionalUserInfo;
//
//  String get username => _userCredential?.additionalUserInfo?.username ?? "";
//
//  bool get isNewUser => _userCredential?.additionalUserInfo?.isNewUser ?? false;
//
//  /// Offers nothing. Merely because the 'mobile version' has this.
//  final List<String> _permissions = List();
//
//  /// Facebook Login List of permissions.
//  List<String> get permissions => _permissions;
//
//  /// Offers nothing. Merely because the 'mobile version' has this.
//  GoogleSignInAccount _googleUser;
//  GoogleSignInAccount get googleUser => _googleUser;
//
//  /// Offers nothing. Merely because the 'mobile version' has this.
//  AuthResult _result;
//  AuthResult get result => _result;
//
//  /// Important to call this function when terminating the you app.
//  void dispose() async {
//    _user = null;
//    _userCredential = null;
//    _auth = null;
//    _listeners.clear();
//    _listeners = null;
//    // Must 'close' the subscription to release resources.
//    await _authListener?.cancel();
//    _authListener = null;
//  }
//
//  Future<bool> alreadyLoggedIn() async {
//    w.User user = await currentUser();
//    return user != null;
//  }
//
//  /// Returns the currently signed-in User or null if there is no one.
//  Future<w.User> currentUser() async {
//    try {
//      _user ??= _auth.currentUser;
//    } catch (ex) {
//      setError(ex);
//      _user = null;
//    }
//    return _user;
//  }
//
//  Exception _ex;
//  String get message => _ex?.toString() ?? "";
//  bool get inError => _ex != null;
//
//  void setError(Object ex) {
//    if (ex is! Exception) {
//      _ex = Exception(ex.toString());
//    } else {
//      _ex = ex;
//    }
//  }
//
//  /// Get the last error but clear it.
//  Exception getError() {
//    Exception ex = _ex;
//    _ex = null;
//    return ex;
//  }
//
//  /// Adds additional OAuth 2.0 scopes that you want to request from the
//  /// authentication provider.
//  bool addScope(String scope) {
//    if (scope == null || scope.isEmpty) return false;
//    return _scopes.add(scope);
//  }
//
//  /// The current Auth instance's language code.
//  /// When set to [:null:], the default Firebase Console language setting
//  /// is applied.
//  /// The language code will propagate to email action templates
//  /// (password reset, email verification and email change revocation),
//  /// SMS templates for phone authentication, reCAPTCHA verifier and OAuth
//  /// popup/redirect operations provided the specified providers support
//  /// localization with the language code specified.
//  void setLanguageCode(String language) {
//    try {
//      _auth.languageCode = language;
//    } catch (ex) {
//      setError(ex);
//    }
//  }
//
//  /// Creates a new user account associated with the specified email address and
//  /// password.
//  ///
//  /// On successful creation of the user account, this user will also be signed
//  /// in to your application.
//  ///
//  /// User account creation can fail if the account already exists or the
//  /// password is invalid.
//  ///
//  /// Note: The email address acts as a unique identifier for the user and
//  /// enables an email-based password reset. This function will create a new
//  /// user account and set the initial user password.
//  Future<bool> createUserWithEmailAndPassword({
//    @required String email,
//    @required String password,
//  }) =>
//      _signIn(() => _auth?.createUserWithEmailAndPassword(email, password));
//
//  /// Returns a list of sign-in methods that can be used to sign in a given
//  /// user (identified by its main email address).
//  ///
//  /// This method is useful when you support multiple authentication mechanisms
//  /// if you want to implement an email-first authentication flow.
//  ///
//  /// Errors:
//  ///   • `ERROR_INVALID_CREDENTIAL` - If the [email] address is malformed.
//  ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address.
//  Future<List<String>> fetchSignInMethodsForEmail({
//    @required String email,
//  }) async {
//    List<String> providers;
//    try {
//      providers = await _auth?.fetchSignInMethodsForEmail(email);
//    } catch (ex) {
//      setError(ex);
//      providers = null;
//    }
//    return providers;
//  }
//
//  /// Checks if an incoming link is a sign-in with email link.
//  bool isSignInWithEmailLink(String emailLink) {
//    bool link;
//    try {
//      link = _auth?.isSignInWithEmailLink(emailLink);
//    } catch (ex) {
//      setError(ex);
//      link = false;
//    }
//    return link;
//  }
//
//  /// Sends a sign-in email link to the user with the specified email.
//  ///
//  /// The sign-in operation has to always be completed in the app unlike other out
//  /// of band email actions (password reset and email verifications). This is
//  /// because, at the end of the flow, the user is expected to be signed in and
//  /// their Auth state persisted within the app.
//  ///
//  /// To complete sign in with the email link, call
//  /// [Auth.signInWithEmailLink] with the email address and
//  /// the email link supplied in the email sent to the user.
//  Future<bool> sendSignInLinkToEmail(String email,
//      [w.ActionCodeSettings actionCodeSettings]) async {
//    bool send;
//    try {
//      await _auth?.sendSignInLinkToEmail(email, actionCodeSettings);
//      send = true;
//    } catch (ex) {
//      setError(ex);
//      send = false;
//    }
//    return send;
//  }
//
//  /// Sends a password reset e-mail to the given [email].
//  /// To confirm password reset, use the [Auth.confirmPasswordReset].
//  ///
//  /// The optional parameter [actionCodeSettings] is the action code settings.
//  /// If specified, the state/continue URL will be set as the 'continueUrl'
//  /// parameter in the password reset link.
//  /// The default password reset landing page will use this to display
//  /// a link to go back to the app if it is installed.
//  ///
//  /// If the [actionCodeSettings] is not specified, no URL is appended to the
//  /// action URL. The state URL provided must belong to a domain that is
//  /// whitelisted by the developer in the console. Otherwise an error will be
//  /// thrown.
//  ///
//  /// Mobile app redirects will only be applicable if the developer configures
//  /// and accepts the Firebase Dynamic Links terms of condition.
//  ///
//  /// The Android package name and iOS bundle ID will be respected only if
//  /// they are configured in the same Firebase Auth project used.
//  Future<bool> sendPasswordResetEmail(String email,
//      [w.ActionCodeSettings actionCodeSettings]) async {
//    bool reset;
//    try {
//      await _auth?.sendPasswordResetEmail(email, actionCodeSettings);
//      reset = true;
//    } catch (ex) {
//      setError(ex);
//      reset = false;
//    }
//    return reset;
//  }
//
//  /// Changes the current type of persistence on the current Auth instance for
//  /// the currently saved Auth session and applies this type of persistence
//  /// for future sign-in requests, including sign-in with redirect requests.
//  /// This will return a Future that will resolve once the state finishes
//  /// copying from one type of storage to the other.
//  /// Calling a sign-in method after changing persistence will wait for that
//  /// persistence change to complete before applying it on the new Auth state.
//  ///
//  /// This makes it easy for a user signing in to specify whether their session
//  /// should be remembered or not. It also makes it easier to never persist
//  /// the Auth state for applications that are shared by other users or have
//  /// sensitive data.
//  ///
//  /// The default is [:'local':] (provided the browser supports this mechanism).
//  ///
//  /// The [persistence] string is the auth state persistence mechanism.
//  /// See allowed [persistence] values in [Persistence] class.
//  Future<bool> setPersistence(String persistence) async {
//    bool set;
//    try {
//      await _auth?.setPersistence(persistence);
//      set = true;
//    } catch (ex) {
//      setError(ex);
//      set = false;
//    }
//    return set;
//  }
//
//  /// The generic 'sign in' routine.
//  Future<bool> _signIn(Future<w.UserCredential> Function() func,
//      [void listener(w.User user)]) async {
//    final loggedIn = await alreadyLoggedIn();
//    if (loggedIn) return loggedIn;
//    // Clear any errors first.
//    getError();
//    bool signIn;
//    addListener(listener);
//    try {
//      _userCredential = await func();
//      signIn = true;
//    } catch (ex) {
//      setError(ex);
//      signIn = false;
//      _userCredential = null;
//      _setUserFromCredential(_userCredential);
//    }
//    removeListener(listener);
//    return signIn;
//  }
//
//  /// Asynchronously signs in with the given credentials, and returns any
//  /// available additional user information, such as user name.
//  Future<bool> signInWithCredential(w.OAuthCredential Function() func,
//      [void listener(w.User user)]) async {
//    w.OAuthCredential credential;
//    bool signIn;
//    try {
//      credential = func();
//      signIn = true;
//    } catch (ex) {
//      setError(ex);
//      signIn = false;
//    }
//    if (signIn)
//      signIn =
//          await _signIn(() => _auth.signInWithCredential(credential), listener);
//    return signIn;
//  }
//
//  /// Asynchronously creates and becomes an anonymous user.
//  ///
//  /// If there is already an anonymous user signed in, that user will be
//  /// returned instead. If there is any other existing user signed in, that
//  /// user will be signed out.
//  ///
//  /// **Important**: You must enable Anonymous accounts in the Auth section
//  /// of the Firebase console before being able to use them.
//  ///
//  /// Errors:
//  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Anonymous accounts are not enabled.
//  Future<bool> signInAnonymously({
//    void listener(w.User user),
//  }) =>
//      _signIn(() => _auth.signInAnonymously(), listener);
//
//  /// Asynchronously signs in using a custom token.
//  ///
//  /// Custom tokens are used to integrate Firebase Auth with existing auth
//  /// systems, and must be generated by the auth backend.
//  ///
//  /// Fails with an error if the token is invalid, expired, or not accepted by
//  /// the Firebase Auth service.
//  Future<bool> signInWithCustomToken({
//    @required String token,
//    void listener(w.User user),
//  }) =>
//      _signIn(() => _auth.signInWithCustomToken(token), listener);
//
//  /// Signs in a user asynchronously using a custom [token] and returns any
//  /// additional user info data or credentials.
//  ///
//  /// This method will be renamed to [signInWithCustomToken()] replacing
//  /// the existing method with the same name in the next major version change.
//  ///
//  /// Custom tokens are used to integrate Firebase Auth with existing auth
//  /// systems, and must be generated by the auth backend.
//  ///
//  /// Fails with an error if the token is invalid, expired, or not accepted by
//  /// the Firebase Auth service.
//  Future<bool> signInAndRetrieveDataWithCustomToken({
//    @required String token,
//    void listener(w.User user),
//  }) =>
//      _signIn(
//          () => _auth.signInAndRetrieveDataWithCustomToken(token), listener);
//
//  /// Asynchronously signs in using an email and password.
//  ///
//  /// Fails with an error if the email address and password do not match.
//  ///
//  /// Note: The user's password is NOT the password used to access the user's
//  /// email account. The email address serves as a unique identifier for the
//  /// user, and the password is used to access the user's account in your
//  /// Firebase project.
//  Future<bool> signInWithEmailAndPassword({
//    @required String email,
//    @required String password,
//    void listener(w.User user),
//  }) =>
//      _signIn(
//          () => _auth.signInWithEmailAndPassword(email, password), listener);
//
//  Future<bool> signInWithEmailLink({
//    String email,
//    String emailLink,
//    void listener(w.User user),
//  }) =>
//      _signIn(() => _auth.signInWithEmailLink(email, emailLink), listener);
//
//  Future<w.ConfirmationResult> signInWithPhoneNumber(
//      String phoneNumber, w.ApplicationVerifier applicationVerifier) async {
//    w.ConfirmationResult result;
//    try {
//      result =
//          await _auth.signInWithPhoneNumber(phoneNumber, applicationVerifier);
//    } catch (ex) {
//      setError(ex);
//      result = null;
//    }
//    return result;
//  }
//
//  /// Does nothing. Merely because the 'mobile version' has this function.
//  Future<bool> signInSilently({
//    String key,
//    String secret,
//    void listener(FirebaseUser user),
//    void listen(GoogleSignInAccount user),
//    bool suppressErrors = true,
//  }) async {
//    return false;
//  }
//
//  /// Signs out the current user and clears it from the disk cache.
//  ///
//  /// If successful, it signs the user out of the app and updates
//  /// the [onAuthStateChanged] stream.
//  Future<void> signOut() => _auth.signOut();
//
//  /// Disconnects the current user from the app and revokes previous
//  /// authentication.
//  Future<void> disconnect() => signOut();
//
//  /// Sets the current language to the default device/browser preference.
//  bool useDeviceLanguage() {
//    bool use;
//    try {
//      _auth?.useDeviceLanguage();
//      use = true;
//    } catch (ex) {
//      setError(ex);
//      use = false;
//    }
//    return use;
//  }
//
//  /// Verifies a password reset [code] sent to the user by email
//  /// or other out-of-band mechanism.
//  /// Returns the user's e-mail address if valid.
//  Future<String> verifyPasswordResetCode(String code) async {
//    String resetCode;
//    try {
//      resetCode = await _auth?.verifyPasswordResetCode(code);
//    } catch (ex) {
//      setError(ex);
//      resetCode = "";
//    }
//    return resetCode;
//  }
//
//  /// Supply a provider if there's options available.
//  _authProvider({
//    @required String type,
//    @required w.AuthProvider provider,
//    String providerId,
//  }) {
//    // Don't bother if already a provider.
//    if (provider != null) return provider;
//    // Check for valid parameter values.
//    if (type == null || type.isEmpty) return provider;
//    type = type.toLowerCase();
//    // Don't bother if nothing to provide.
//    if (_scopes.isEmpty &&
//        (_customOAuthParameters == null || _customOAuthParameters.isEmpty))
//      return provider;
//    Iterator<String> it = _scopes.iterator;
//    var newProvider;
//    if (type == 'facebook') {
//      newProvider = w.FacebookAuthProvider();
//    } else if (type == 'github') {
//      newProvider = w.GithubAuthProvider();
//    } else if (type == 'google') {
//      newProvider = w.GoogleAuthProvider();
//    } else if (type == 'oauth' && providerId != null && providerId.isNotEmpty) {
//      newProvider = w.OAuthProvider(providerId);
//    } else if (type == 'twitter') {
//      newProvider = w.TwitterAuthProvider();
//      // Twitter has no scope.
//      it = List<String>().iterator;
//    } else {
//      // Return the unknown provider.
//      return provider;
//    }
//    while (it.moveNext()) {
//      newProvider.addScope(it.current);
//    }
//    if (_customOAuthParameters != null && _customOAuthParameters.isNotEmpty)
//      newProvider.setCustomParameters(_customOAuthParameters);
//    // Assign the 'new' provider to the memory reference.
//    return newProvider;
//  }
//
//  /// Generic routine supplied with an Authentication Provider.
//  Future<bool> signInWithProvider(
//    w.AuthProvider provider,
//    void listener(w.User user), {
//    bool popup = true,
//  }) async {
//    if (provider == null) return false;
//    return _signIn(() async {
//      w.UserCredential credential;
//      if (popup) {
//        credential = await _auth.signInWithPopup(provider);
//      } else {
//        // Using a redirect.
//         await  _auth.getRedirectResult().then((w.UserCredential credential) {
//           _userCredential = credential;
//           _setUserFromCredential(_userCredential);
//         }).catchError((error) {
//          setError(error);
//        });
//        _auth.signInWithRedirect(provider);
//      }
//      return credential;
//    }, listener);
//  }
//
//  Future<bool> signInWithEmail({
//    String email,
//    String password,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    email ??= _email;
//    password ??= _password;
//    if (_emailAuth == null) {
//      if (email == null ||
//          email.isEmpty ||
//          password == null ||
//          password.isEmpty) {
//        return false;
//      } else {
//        return signInWithCredential(
//          () => w.EmailAuthProvider.credential(email, password),
//          listener,
//        );
//      }
//    } else {
//      return signInWithProvider(_emailAuth, listener, popup: popup);
//    }
//  }
//
//  Future<bool> signInWithFacebook({
//    String token,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    token ??= _token;
//    if (_facebookAuth == null) {
//      if (token != null && token.isNotEmpty) {
//        return signInWithCredential(
//          () => w.FacebookAuthProvider.credential(token),
//          listener,
//        );
//      }
//      _facebookAuth = _authProvider(type: 'facebook', provider: _facebookAuth);
//    }
//    return signInWithProvider(_facebookAuth, listener, popup: popup);
//  }
//
//  Future<bool> signInWithGithub({
//    String token,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    token ??= _token;
//    if (_githubAuth == null) {
//      if (token != null && token.isNotEmpty) {
//        return signInWithCredential(
//          () => w.GithubAuthProvider.credential(token),
//          listener,
//        );
//      }
//      _githubAuth = _authProvider(type: 'github', provider: _githubAuth);
//    }
//    return signInWithProvider(_githubAuth, listener, popup: popup);
//  }
//
//  Future<bool> signInWithGoogle({
//    String idToken,
//    String accessToken,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    idToken ??= _idToken;
//    accessToken ??= _accessToken;
//    if (_googleAuth == null) {
//      if (idToken != null &&
//          idToken.isNotEmpty &&
//          accessToken != null &&
//          accessToken.isNotEmpty) {
//        return signInWithCredential(
//          () => w.GoogleAuthProvider.credential(idToken, accessToken),
//          listener,
//        );
//      }
//      _googleAuth = _authProvider(type: 'google', provider: _googleAuth);
//    }
//    return signInWithProvider(_googleAuth, listener, popup: popup);
//  }
//
//  Future<bool> signInWithOAuth(String providerId,
//      {String idToken,
//      String accessToken,
//      void listener(w.User user),
//      bool popup = true}) async {
//    if (providerId == null || providerId.isEmpty) return false;
//    idToken ??= _idToken;
//    accessToken ??= _accessToken;
//    if (_oAuth == null) {
//      if (idToken != null &&
//          idToken.isNotEmpty &&
//          accessToken != null &&
//          accessToken.isNotEmpty) {
//        try {
//          _oAuth = w.OAuthProvider(providerId);
//        } catch (ex) {
//          setError(ex);
//          return false;
//        }
//        return signInWithCredential(
//          () => _oAuth.credential(idToken, accessToken),
//          listener,
//        );
//      }
//      _oAuth = _authProvider(
//          type: 'oauth', provider: _oAuth, providerId: providerId);
//    }
//    return signInWithProvider(_oAuth, listener, popup: popup);
//  }
//
//  Future<bool> signInWithTwitter({
//    String key,
//    String secret,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    String token = key ?? _token;
//    secret ??= _secret;
//    if (_twitterAuth == null) {
//      if (token != null &&
//          token.isNotEmpty &&
//          secret != null &&
//          secret.isNotEmpty) {
//        return await signInWithCredential(
//          () => w.TwitterAuthProvider.credential(token, secret),
//          listener,
//        );
//      }
//      _twitterAuth = _authProvider(type: 'twitter', provider: _twitterAuth);
//    }
//    return signInWithProvider(_twitterAuth, listener, popup: popup);
//  }
//
//  /// Starts a phone number authentication flow by sending a verification code
//  /// to the given [phoneNumber] in E.164 format (e.g. +16505550101).
//  Future<bool> signInWithPhone({
//    String phoneNumber,
//    bool popup = true,
//    void listener(w.User user),
//  }) async {
//    phoneNumber ??= _phoneNumber;
//    if (_phoneAuth == null) {
//      w.PhoneAuthProvider phone = w.PhoneAuthProvider(_auth);
//      w.ApplicationVerifier verifier = w.RecaptchaVerifier('register', {
//        'size': 'invisible',
//        'callback': (resp) {
//          print('Successful reCAPTCHA response');
//        },
//        'expired-callback': () {
//          print('Response expired');
//        }
//      });
//      String verificationId =
//          await phone.verifyPhoneNumber(phoneNumber, verifier);
//      String verificationCode = await verifier.verify();
//      return signInWithCredential(
//        () => w.PhoneAuthProvider.credential(verificationId, verificationCode),
//        listener,
//      );
//    }
//    return signInWithProvider(_phoneAuth, listener, popup: popup);
//  }
//
//  Future<bool> _setUserFromCredential(w.UserCredential credential) async {
//    _accessToken = credential?.credential?.accessToken ?? "";
//    return _setUserFromWebUser(credential?.user);
//  }
//
//  Future<bool> _setUserFromWebUser(w.User user) async {
//    _user = user;
//
//    _idTokenResult = await _user?.getIdTokenResult();
//
//    _idToken = _idTokenResult?.token ?? "";
//
//    _isEmailVerified = _user?.emailVerified ?? false;
//
//    _isAnonymous = _user?.isAnonymous ?? true;
//
//    _displayName = _user?.displayName ?? "";
//
//    _email = _user?.email ?? "";
//
//    _phoneNumber = _user?.phoneNumber ?? "";
//
//    _photoUrl = _user?.photoURL ?? "";
//
//    _providerId = _user?.providerId ?? "";
//
//    _uid = _user?.uid ?? "";
//
//    return _uid.isNotEmpty;
//  }
//
//  /// Deletes and signs out the user.
//  Future<bool> delete() async {
//    bool delete;
//    try {
//      _user.delete();
//      delete = true;
//    } catch (ex) {
//      setError(ex);
//      delete = false;
//    }
//    return delete;
//  }
//
//  /// Returns a JWT token used to identify the user to a Firebase service.
//  ///
//  /// Returns the current token if it has not expired, otherwise this will
//  /// refresh the token and return a new one.
//  ///
//  /// It forces refresh regardless of token expiration if [forceRefresh]
//  /// parameter is `true`.
//  Future<String> getIdToken([bool forceRefresh = false]) async {
//    String id;
//    try {
//      id = await _user?.getIdToken(forceRefresh);
//    } catch (ex) {
//      setError(ex);
//      id = null;
//    }
//    return id;
//  }
//
//  /// Links the user account with the given credentials, and returns any
//  /// available additional user information, such as user name.
//  Future<w.UserCredential> linkWithCredential(w.OAuthCredential oauth) async {
//    w.UserCredential credential;
//    try {
//      credential = await _user?.linkWithCredential(oauth);
//    } catch (ex) {
//      setError(ex);
//      credential = null;
//    }
//    return credential;
//  }
//
//  /// Links the user account with the given [phoneNumber] in E.164 format
//  /// (e.g. +16505550101) and [applicationVerifier].
//  Future<w.ConfirmationResult> linkWithPhoneNumber(
//      String phoneNumber, w.ApplicationVerifier applicationVerifier) async {
//    w.ConfirmationResult result;
//    try {
//      result =
//          await _user?.linkWithPhoneNumber(phoneNumber, applicationVerifier);
//    } catch (ex) {
//      setError(ex);
//      result = null;
//    }
//    return result;
//  }
//
//  /// Links the authenticated [provider] to the user account using
//  /// a pop-up based OAuth flow.
//  /// It returns the [UserCredential] information if linking is successful.
//  Future<w.UserCredential> linkWithPopup(w.AuthProvider provider) async {
//    w.UserCredential credential;
//    try {
//      credential = await _user?.linkWithPopup(provider);
//    } catch (ex) {
//      setError(ex);
//      credential = null;
//    }
//    return credential;
//  }
//
//  /// Links the authenticated [provider] to the user account using
//  /// a full-page redirect flow.
//  Future<bool> linkWithRedirect(w.AuthProvider provider) async {
//    bool redirect;
//    try {
//      await _user.linkWithRedirect(provider);
//      redirect = true;
//    } catch (ex) {
//      setError(ex);
//      redirect = false;
//    }
//    return redirect;
//  }
//
//  /// Re-authenticates a user using a fresh credential, and returns any
//  /// available additional user information, such as user name.
//  Future<w.UserCredential> reauthenticateWithCredential(
//      w.OAuthCredential oauth) async {
//    w.UserCredential credential;
//    try {
//      credential = await _user?.reauthenticateWithCredential(oauth);
//    } catch (ex) {
//      setError(ex);
//      credential = null;
//    }
//    return credential;
//  }
//
//  /// Reauthenticates a user with the specified provider using
//  /// a pop-up based OAuth flow.
//  /// It returns the [UserCredential] information if reauthentication is successful.
//  Future<w.UserCredential> reauthenticateWithPopup(
//      w.AuthProvider provider) async {
//    w.UserCredential credential;
//    try {
//      credential = await _user?.reauthenticateWithPopup(provider);
//    } catch (ex) {
//      setError(ex);
//      credential = null;
//    }
//    return credential;
//  }
//
//  /// Reauthenticates a user with the specified OAuth [provider] using
//  /// a full-page redirect flow.
//  Future<bool> reauthenticateWithRedirect(w.AuthProvider provider) async {
//    bool redirect;
//    try {
//      await _user.reauthenticateWithRedirect(provider);
//      redirect = true;
//    } catch (ex) {
//      setError(ex);
//      redirect = false;
//    }
//    return redirect;
//  }
//
//  /// If signed in, it refreshes the current user.
//  Future<bool> reload() async {
//    bool reload;
//    try {
//      await _user.reload();
//      reload = true;
//    } catch (ex) {
//      setError(ex);
//      reload = false;
//    }
//    return reload;
//  }
//
//  /// Sends an e-mail verification to a user.
//  ///
//  /// The optional parameter [actionCodeSettings] is the action code settings.
//  /// If specified, the state/continue URL will be set as the 'continueUrl'
//  /// parameter in the email verification link.
//  /// The default email verification landing page will use this to display
//  /// a link to go back to the app if it is installed.
//  ///
//  /// If the [actionCodeSettings] is not specified, no URL is appended to the
//  /// action URL. The state URL provided must belong to a domain that is
//  /// whitelisted by the developer in the console. Otherwise an error will be
//  /// thrown.
//  ///
//  /// Mobile app redirects will only be applicable if the developer configures
//  /// and accepts the Firebase Dynamic Links terms of condition.
//  ///
//  /// The Android package name and iOS bundle ID will be respected only if
//  /// they are configured in the same Firebase Auth project used.
//  Future<bool> sendEmailVerification() async {
//    bool sent;
//    try {
//      await _user.sendEmailVerification();
//      sent = true;
//    } catch (ex) {
//      setError(ex);
//      sent = false;
//    }
//    return sent;
//  }
//
//  /// Unlinks a provider with [providerId] from a user account.
//  Future<w.User> unlink(String providerId) async {
//    w.User user;
//    try {
//      user = await _user?.unlink(providerId);
//    } catch (ex) {
//      setError(ex);
//      user = null;
//    }
//    return user;
//  }
//
//  /// Updates the user's e-mail address to [newEmail].
//  Future<bool> updateEmail(String email) async {
//    bool update;
//    try {
//      _user.updateEmail(email);
//      update = true;
//    } catch (ex) {
//      setError(ex);
//      update = false;
//    }
//    return update;
//  }
//
//  /// Updates the user's password to [newPassword].
//  /// Requires the user to have recently signed in. If not, ask the user
//  /// to authenticate again and then use [reauthenticate()].
//  Future<bool> updatePassword(String password) async {
//    bool update;
//    try {
//      _user.updatePassword(password);
//      update = true;
//    } catch (ex) {
//      setError(ex);
//      update = false;
//    }
//    return update;
//  }
//
//  /// Updates the user's phone number.
//  Future<bool> updatePhoneNumber(w.OAuthCredential phoneCredential) async {
//    bool update;
//    try {
//      await _user?.updatePhoneNumber(phoneCredential);
//      update = true;
//    } catch (ex) {
//      setError(ex);
//      update = false;
//    }
//    return update;
//  }
//
//  /// Updates a user's profile data.
//  Future<bool> updateProfile(w.UserProfile profile) async {
//    bool update;
//    try {
//      await _user.updateProfile(profile);
//      update = true;
//    } catch (ex) {
//      setError(ex);
//      update = false;
//    }
//    return update;
//  }
//
//  /// The authentication time. The ID token.   expiration time.
//  /// The sign-in provider.  The Firebase Auth ID token JWT string.
//  Future<w.IdTokenResult> getIdTokenResult({bool forceRefresh = false}) async {
//    w.IdTokenResult result;
//    try {
//      result = await _user.getIdTokenResult(forceRefresh);
//    } catch (ex) {
//      setError(ex);
//      result = null;
//    }
//    return result;
//  }
//
//  /// Returns a JSON-serializable representation of this object.
//  Map<String, dynamic> toJson() {
//    Map<String, dynamic> json;
//    try {
//      json = _user.toJson();
//    } catch (ex) {
//      setError(ex);
//      json = {};
//    }
//    return json;
//  }
//
//  /// FireBase Logged in.
//  Future<bool> isLoggedIn() async {
//    w.User user = await currentUser();
//    return user != null && user.uid.isNotEmpty;
//  }
//
//  /// Google Signed in.
//  Future<bool> isSignedIn() async {
//    bool isSignedIn;
//    isSignedIn = await isLoggedIn();
//    if (isSignedIn) {
//      w.AdditionalUserInfo info = _userCredential.additionalUserInfo;
//      isSignedIn = info != null;
//      if (isSignedIn)
//        isSignedIn = info.providerId == w.GoogleAuthProvider.PROVIDER_ID;
//    }
//    return isSignedIn;
//  }
//
//  /// True if signed into Firebase
//  bool signedInFirebase() => !signedInGoogle();
//
//  /// True if signed into a Google account
//  bool signedInGoogle() {
//    bool isSignedIn = false;
//    w.AdditionalUserInfo info = _userCredential?.additionalUserInfo;
//    if (info != null)
//      isSignedIn = info.providerId == w.GoogleAuthProvider.PROVIDER_ID;
//    return isSignedIn;
//  }
//
//  /// Creates (and initializes) a Firebase App with API key, auth domain,
//  /// database URL and storage bucket.
//  static w.App initializeApp(
//      {String apiKey,
//      String authDomain,
//      String databaseURL,
//      String projectId,
//      String storageBucket,
//      String messagingSenderId,
//      String name,
//      String measurementId,
//      String appId}) {
//    w.App app;
//    try {
//      app = w.initializeApp(
//        apiKey: apiKey,
//        authDomain: authDomain,
//        databaseURL: databaseURL,
//        projectId: projectId,
//        storageBucket: storageBucket,
//        messagingSenderId: messagingSenderId,
//        name: name,
//        measurementId: measurementId,
//        appId: appId,
//      );
//    } catch (ex) {
//      app = null;
//    }
//    // Assign to the instance variable if not already assigned an app.
//    _app ??= app;
//    return app;
//  }
//
//  /// Retrieves an instance of an [App].
//  ///
//  /// With no arguments, this returns the default App. With a single
//  /// string argument, it returns the named App.
//  static w.App app([String name]) {
//    w.App app;
//    try {
//      app = w.app(name);
//    } catch (ex) {
//      app = null;
//    }
//    return app;
//  }
//}
