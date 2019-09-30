## 3.2.1
- if (_fireBaseListeners == null) return;
- Update pubspec.yaml dependencies
- Update README.md

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