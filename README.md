# Auth Class
This class library works with two plugins: [firebase_auth ](https://pub.dartlang.org/packages/firebase_auth) and [google_sign_in](https://pub.dartlang.org/packages/google_sign_in) to log into a Firebase backend using a Firebase account or a Google account. If you're familiar with these plugins, you will find the same functions used in this class library. 
## How it Works
Below are a series of screenshots depicting how to initialize and authenticate or 'sign in' an individual in your app's Firebase backend using a either an email and password or a Google account. The following will sign in 'silently' (i.e. automatically if the user had already signed in in the past.). Note, settings are passed as parameters in the screenshot below. 
![09inistate](https://user-images.githubusercontent.com/32497443/42516830-7590ed4e-842c-11e8-9457-01e82876f8ce.png)
These examples have the class library called in the State object's **iniState**() function, but, of course, you could instead 'initialize' the class library in the **iniState**() function and then 'sign in' elsewhere. Below, the **init**() function is used instead to initialize the class library. 

![authinit](https://user-images.githubusercontent.com/32497443/42482917-7b5b5c42-83b8-11e8-9dbf-6c1918ce64b0.png) 
## There's Setters 
The class library provide an array of setters that you can use instead to first initialize. The 'listen' setter will call the anonymous function when the user either successfully or unsuccessfully logs in. 
![authset](https://user-images.githubusercontent.com/32497443/42482931-8e75cd80-83b8-11e8-9b08-cb0cec03e9d7.png)
## The Last Setter Wins
By design, the last assignment of a particular setting is the one used by the class library. The the example blow, there is a stretch of code that calls the 'scopes' setting twice. The last instance (in the **signInSliently**() function) will be the one used.
![twoscopes](https://user-images.githubusercontent.com/32497443/42482949-a43130a6-83b8-11e8-807d-896fa49202ce.png)
Below is a snapshot of the **logInWithGoogle**() function inside the class library itself.
It is this function you will likely use the most. It does the majority of the functionality. It will log in 'silently' if possible, otherwise it will use the user's Google account to log into Firebase. This snapshot gives you an idea of the parameters (options) you have available to you. Again, if you're familiar with the plugins, you'll recognize most of these parameters.
![loginwithgoogle](https://user-images.githubusercontent.com/32497443/42518643-50acfc94-8430-11e8-94c0-622ca8224fb5.png)

![signingin](https://user-images.githubusercontent.com/32497443/42482901-603f9d7e-83b8-11e8-8388-f5f980f931b9.png)

## It's All Static
It's a static class library, and so prefix the word, 'Auth', in front of the function call 'anytime anywhere' in the app, and you're off and running.
![authcalls](https://user-images.githubusercontent.com/32497443/42484604-af25c978-83c1-11e8-8a23-bd2e5017ba76.png)

##### On Medium
This is a library is covered again in the Medium article, [Auth in Flutter](https://medium.com/flutter-community/auth-in-flutter-3f4ffe0ddcf8).
[![auth](https://user-images.githubusercontent.com/32497443/49756376-f66e2c00-fc87-11e8-83f6-a112b8f126a5.png)](https://medium.com/flutter-community/auth-in-flutter-3f4ffe0ddcf8)
# DECODE Flutter
##### Live Streaming every week. Everything to do about Flutter. 
[![twitch](https://user-images.githubusercontent.com/32497443/49753449-7349d780-fc81-11e8-9d08-89146a6731c8.png)
](https://medium.com/@greg.perry/decode-flutter-6b60a3199e83)