# Auth Class
This class library works with two plugins: [firebase_auth ](https://pub.dartlang.org/packages/firebase_auth) and [google_sign_in](https://pub.dartlang.org/packages/google_sign_in) to log into a Firebase backend using a Firebase account or a Google account. If you're familiar with these plugins, you will find the same functions used in this class library. 
## How it Works
Below are a series of screenshots depicting how to initialize and authenticate or 'sign in' an individual into your app's Firebase database using a either an email and password or a Google account. The following will sign in 'silently' (i.e. automatically if the user had already signed in in the past.). Note, settings are passed as parameters in the screenshot below. 
![09inistate](https://user-images.githubusercontent.com/32497443/62817460-d9327b80-bafc-11e9-9e96-4ce2682d49e5.png)
These examples have the class library called in the State object's **iniState**() function, but, of course, you could instead 'initialize' the class library in the **initState**() function and then 'sign in' elsewhere. Below, the **init**() function is used instead just to initialize the class library. 
![authinit](https://user-images.githubusercontent.com/32497443/62817491-5f4ec200-bafd-11e9-9197-4df5c3cd6180.png) 
![auth3](https://user-images.githubusercontent.com/32497443/62818193-c1adbf80-bb09-11e9-966b-65a02f03e8c9.png)
![anyomous](https://user-images.githubusercontent.com/32497443/62819280-7d75eb80-bb18-11e9-89a5-6aaf3d1a4214.png)
![google](https://user-images.githubusercontent.com/32497443/62819365-deea8a00-bb19-11e9-9ce5-98ee6c5f2218.png)
![properties](https://user-images.githubusercontent.com/32497443/62819111-2f5fe880-bb16-11e9-80d2-181a7f845bb3.png)
##### On Medium
This is a class library is covered again in the Medium article, [Auth in Flutter](https://medium.com/@greg.perry/auth-in-flutter-97275b29b550).
[![AuthArticle](https://user-images.githubusercontent.com/32497443/62817669-18160080-bb00-11e9-9279-304cec3ff95f.png)](https://medium.com/@greg.perry/auth-in-flutter-97275b29b550)
