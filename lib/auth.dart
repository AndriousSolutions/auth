///
/// Copyright (C) 2020 Andrious Solutions
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
///          Created  12 Feb 2020
///
///

export 'package:auth/src/auth.dart';

// This works! Supply them through this dart file
export 'package:firebase_auth/firebase_auth.dart'
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

// This works! Supply them through this dart file
export 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
