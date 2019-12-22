# Auth 

This library package works with four plugins: 
- [firebase_auth ](https://pub.dartlang.org/packages/firebase_auth)
- [google_sign_in](https://pub.dartlang.org/packages/google_sign_in)
- [flutter_facebook_login](https://pub.dev/packages/flutter_facebook_login)
- [flutter_twitter](https://pub.dartlang.org/packages/flutter_twitter)

All four are used to log into a Firebase backend. If you're familiar with these plugins, you'll be able to quickly use this class library. 

## Installing

I don't always like the version number always suggested in the '[Installing](https://pub.dev/packages/auth#-installing-tab-)' page.
Instead, always go up to the '**major**' semantic version number when installing my library packages. This means always entering a version number trailing with two zero, '**.0.0**'. This allows you to take in any '**minor**' versions introducing new features as well as any '**patch**' versions that involves bugfixes. Semanitic version numbers are always in this format: **major.minor.patch**. 

1. **patch** - I've made bugfixes
2. **minor** - I've introduced new features
3. **major** - I've essentially made a new app. It's broken backwards-compatibility and has a completely new the user experience. You won't get this version until you increment the **major** number in the pubspec.yaml file.

And so, in this case, add this to your package's pubspec.yaml file instead:

```yaml
dependencies:
  auth:^4.0.0
```

For more information on this topic, read the article, [The importance of semantic versioning](https://medium.com/@xabaras/the-importance-of-semantic-versioning-9b78e8e59bba).

# How it Works

Below are a series of screenshots depicting how to initialize and authenticate or 'sign in' an individual into your app's Firebase database using a either an email and password or a Google account. The following will sign in 'silently' (i.e. automatically if the user had already signed in in the past.). Note, settings are passed as parameters in the screenshot below. 

```dart
auth = Auth.init(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
    listener: (user) {
      loggedIn = user != null;
      setState(() {});
    });

auth.signInSilently(
  listen: (account) {
    loggedIn = account != null;
    setState(() {});
  },
);
```

These examples have the class library called in the State object's **`initState()`** function, but, of course, you could instead 'initialize' the class library in the **`initState()`** function and then **'sign in'** elsewhere. Below, the **`init()`** function is used instead just to initialize the class library. 

```dart
@override
void initState() {
  super.initState();

  auth = Auth.init(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
    listener: (user) {
      loggedIn = user != null;
      setState(() {});
    },
    listen: (account) {
      loggedIn = account != null;
      setState(() {});
    },
  );
  
  auth.signInSilently();
}

@override
void dispose() {
  /// Important to dispose of the Auth's resources.
  auth.dispose();
  super.dispose();
}
```
## Screenshots

[![auth3](https://user-images.githubusercontent.com/32497443/62818193-c1adbf80-bb09-11e9-966b-65a02f03e8c9.png)](https://github.com/AndriousSolutions/auth/blob/fab7e97246581fa4b6ad91fa95a9d10124347f2c/example/main.dart#L92)
![anyomous](https://user-images.githubusercontent.com/32497443/62819280-7d75eb80-bb18-11e9-89a5-6aaf3d1a4214.png)
![google](https://user-images.githubusercontent.com/32497443/62819365-deea8a00-bb19-11e9-9ce5-98ee6c5f2218.png)

```dart
Widget get _authResults => ListView(
      padding: const EdgeInserts.all(30.0),
      itemExtent: 80.0,
      children: <Widget>[
        Text("uid: ${auth.uid}"),
        Text("name: ${auth.displayName}"),
        Text("photo: ${auth.photoUrl}"),
        Text("new login: ${auth.isNewUser}"),
        Text("user name: ${auth.username}"),
        Text("email: ${auth.email}"),
        Text("email verified: ${auth.isEmailVerified}"),
        Text("anonymous login: ${auth.isAnonymous}"),
        Text("id token: ${auth.idToken}"),
        Text("access token: ${auth.accessToken}"),
        Text("information provider: ${auth.providerId}"),
        Text("expire time: ${auth.expirationTime}"),
        Text("auth time: ${auth.authTime}"),
        Text("issued at: ${auth.issuedAtTime}"),
        Text("signin provider: ${auth.signInProvider}"),
      ], // <Widget>[]
    ); // ListView
```

# Providers

This package works with multiple auth providers including Facebook and Twitter.

## Facebook
Even if you've no intention of allowing users to use Facebook to log in, you will have to modify a few files any way so to use this library package. You can then ignore these files as they just need to be there. If you don't add to these three files, you'll get the following error when trying to use this Auth package:

```
The SDK has not been initialized, make sure to call FacebookSdk.sdkInitialize() first.
```
![faceSDKerror](https://user-images.githubusercontent.com/32497443/66129610-dceef580-e5b5-11e9-81ee-f1c4fde18037.png)

### On The Android Side

You must acknowledge to Android that the Facebook SDK is being utilized. Hence, a means to initialize it is required. So, go to the 'Android Manifest file' (*android/app/src/main/AndroidManifest.xml*) and add the following _after_ the first tag, `</activity>` but **before** the last tag, `</application>`. See below:

![facebookManifest](https://user-images.githubusercontent.com/32497443/66130625-9dc1a400-e5b7-11e9-87e9-46659eb5baa2.png)

You can copy and paste the code here:

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id"/>

<activity android:name="com.facebook.FacebookActivity"
    android:configChanges=
            "keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />

<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```
Now go to the 'styles' (android/app/src/main/res/values/styles.xml) file and add the following:

```xml
<string name="app_name">Your App Name here.</string>
<!-- Replace "000000000000" with your Facebook App ID here. -->
<string name="facebook_app_id">000000000000</string>
<!-- Replace "000000000000" with your Facebook App ID here.    -->
<string name="fb_login_protocol_scheme">fb000000000000</string>
```

With that, you can get on with your app even if you're not going to log in with Facebook. Here's what it would possibly look like in your particular file:

![facebookresfile](https://user-images.githubusercontent.com/32497443/66132145-3e18c800-e5ba-11e9-912e-4ae0b19e6dce.png)

**Note:** Place this file in .gitignore so not to save this Facebook App ID numbers on a public Github repository.

## Setup Facebook Login

You will have to go to your [Facebook Developers](https://developers.facebook.com/apps/) account and create or select the app you'll use. 

Under Settings, click on the show button to copy down your **App ID** and **App Secret** those later (_Firebase will need them_). 

![AppSecret](https://user-images.githubusercontent.com/32497443/66141106-c8682880-e5c8-11e9-8b9a-dc3f21541d07.png)

Read [quickstart section](https://developers.facebook.com/docs/facebook-login/android) from Facebook documentation to set up Facebook on the Android side.

The following steps in particular will get your app working with Facebook:

1. Select an App or Create a New App
2. Edit Your Resources and Manifest
3. Associate Your Package Name and Default Class with Your App
4. Provide the Development and Release Key Hashes for Your App

## Tell Firebase

Remember, all this effort is to connect to a backend Firebase database. You some things to do in the [Firebase Projects Console](https://console.firebase.google.com/u/0/?pli=1).

You'll have to go into the _Sign-in method_ tab and enable the Facbook option and any other options you may wish to use to log into this Firebase app:

![signInProviders](https://user-images.githubusercontent.com/32497443/66139701-7f16d980-e5c6-11e9-8dd4-48e7fe81f61a.png)

## Use Twitter

You can use Twitter as well if you want to. You'll just need to create an app on Twitter and then supply the **Consumer API keys** to this library package.

[Go to Twitter Apps page](https://developer.twitter.com/en/apps)

![keysTokens](https://user-images.githubusercontent.com/32497443/66142518-2990fb80-e5cb-11e9-9f84-7f1e03ae2e2e.png)

#### On Medium

This is a class library is covered again in the Medium article, [Auth in Flutter](https://medium.com/@greg.perry/auth-in-flutter-97275b29b550).

[![AuthArticle](https://user-images.githubusercontent.com/32497443/62817669-18160080-bb00-11e9-9279-304cec3ff95f.png)](https://medium.com/@greg.perry/auth-in-flutter-97275b29b550)

#### Other Dart Packages
Other Dart packages from the author can also be found at [Pub.dev](https://pub.dev/packages?q=email%3Asupport%40andrioussolutions.com)
