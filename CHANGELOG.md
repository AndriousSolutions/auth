## 7.3.2+2
 January 13, 2021
- sdk: '>=2.10.0 <3.0.0'
- firebase_core: '>=0.7.0 <1.0.0'
- firebase_auth: '>=0.20.0 <1.0.0'
- flutter_login_facebook: '>=0.4.2 <1.0.0'

## 7.3.1
 December 25, 2020
- Updated flutter_login_facebook: 0.4.2

## 7.3.0
 November 26, 2020
- Updated flutter_login_facebook ^0.2.0
- Stricter Lint Rules

## 7.2.0
 October 06, 2020
- Include await Firebase.initializeApp(); in firebase_core: ^0.5.0

## 7.1.0
 September 30, 2020
- Updated dependency:
 flutter_login_facebook
 
## 7.0.1
 September 03, 2020
- getRedirectResult()
- isSignInWithEmailLink()
- idTokenChanges()
- userChanges()
- setSettings()
- checkActionCode()
- applyActionCode()

## 7.0.0
 September 02, 2020
- Upgrade to firebase_auth 0.18.0+1
- **BREAKING:** The FirebaseUser class has been renamed to User.
- currentUser() to getter currentUser.
- **DEPRECATED:** updatePhoneNumberCredential(); to updatePhoneNumber();
- **BREAKING:** Accessing the current user via currentUser() is now synchronous via the currentUser getter.
- **BREAKING:** alreadyLoggedIn(), isLoggedIn() and isSignInWithEmailLink() is now synchronous.
- **BREAKING:** unlinkFromProvider() no longer functional.
- **DEPRECATED:** FirebaseAuth.fromApp() is now deprecated in favor of FirebaseAuth.instanceFor().
- **DEPRECATED:** onAuthStateChanged has been deprecated in favor of authStateChanges().

## 6.1.0
 August 19, 2020
- Format code to Strict Flutter lint rules
- setError() catches 'network_error' #7

## 6.0.4
 August 17, 2020
- try-catch on getIdToken();

## 6.0.3
 June 03, 2020
- Corrected Apache Licence.

## 6.0.2
- Replaced deprecated api with flutter_twitter_login:

## 6.0.1
- upgrade to firebase_auth: ^0.16.0

## 6.0.0
- Replaced plugin flutter_facebook_login with flutter_login_facebook

## 5.0.2
- if (_fireBaseListeners != null) // Odd error at times. gp

## 5.0.1
- Initialize Set variables in the constructor.

## 5.0.0
- Separate 'web version' in auth_web.dart

## 4.2.0
- if(kIsWeb) return false;  Allow package on Flutter Web.

## 4.1.0
- Reordered routines in signInSilently() Try Twitter, Facebook then Google signIn's

## 4.0.2
 December 10, 2019
- SignInOption signInOption = SignInOption.standard

## 4.0.1
 November 26, 2019
- **Fix Breaking Change**  google_sign_in_platform_interface: ^1.0.0
- firebase_auth: ^0.15.0

## 4.0.0
 October 02, 2019
- removed signIn()
- new signInSilently()
- new signInWithGoogleSilently()
- new signInWithFacebook()
- new signInWithFacebookSilently()
- new signInFacebook()
- new signInWithTwitter()
- new signInWithTwitterSilently()
- new signInTwitter()
- new addListen(f) 
- deprecated googleListener(f)
- new addListener(f) 
- deprecated fireBaseListener(f)
- createUserWithEmailAndPassword() allowed if logged in
- addListener(f) in signInAnonymously()
- addListener(f) in signInWithCredential()
- addListener(f) in signInWithCustomToken()
- addListener(f) in signInWithEmailAndPassword()
 October 01, 2019
- user = await currentUser();
- plugin flutter_twitter
- plugin flutter_facebook_login
- delete folder src\oauth
        
## 3.2.0
- Provided new functions:
getIdToken();              updatePhoneNumberCredential(); 
linkWithCredential();      updatePassword();
sendEmailVerification();   updateProfile(); 
reload();                  reauthenticateWithCredential();         
delete();                  unlinkFromProvider();
updateEmail(); 
  
## 3.1.1
- set listen(GoogleListener f) => _googleListeners.add(f);

## 3.1.0
- void return type in some functions.
- Introduced the setters, listener and listen.

## 3.0.0
 August 06, 2019
- Removed parameters onError, onDone(), and cancelOnError from the Constructor
- Introduced getEventErrors() and eventErrors
- CustomAlertDialog class in example app

## 2.1.0
 August 02, 2019
- Introduced signedInGoogle(), signedInFirebase()
- Adjusted example main.dart

## 2.0.0
 August 02, 2019
- Abandoned the Singleton design pattern
- Factory constructor to ensure only one Auth instance.
- Renamed signIn functions.

## 1.3.1
 August 02, 2019
- Removed properties: signInOption scopes hostedDomain onError, onDone, cancelOnError
- Set{} for list of listeners
- Rearranged code for readability

## 1.3.0
 August 02, 2019
- async isSignedIn(), isLoggedIn()
- Library-private _initFireBase()
- _setUserFromFireBase() in _listFireBaseListeners()
- _setFireBaseUserFromGoogle() in _listGoogleListeners()
- Introduced IdTokenResult
- if (ex is! Exception) {

## 1.2.1
 July 29, 2019
- Latest firebase_auth version
- Format code 
- signInWithTwitter()

## 1.2.0
- Include the new classes AuthResult and AdditionalUserInfo from firebase_auth
 
## 1.1.0+1
 Mar. 21, 2019  
- move FlutterOAuth library to oauth directory

## 1.1.0
 Mar. 21, 2019  
- incorporated Joe Birch's FlutterOAuth library
- introduced signInWithFacebook() function 

## 1.0.1
 Mar. 07, 2019  
- import 'package:flutter/material.dart';

## 1.0.0
 Mar. 07, 2019  
- Added signInWithCredential, linkWithCredential, fetchSignInMethodsForEmail
- **Breaking Change** Removed signInWithFacebook, signInWithTwitter, signInWithGoogle, 
- **Breaking Change** linkWithEmailAndPassword, linkWithGoogleCredential, linkWithFacebookCredential

## 0.1.1 
 Jan. 17, 2019  
- await _setFireBaseUserFromGoogle(currentUser);

## 0.1.0 
 Dec. 10, 2018
- Change semantic version number to convey development phase.

## 0.0.3
- await _user?.reload();

## 0.0.2
- Format code with dartfmt

## 0.0.1 
- Initial github release