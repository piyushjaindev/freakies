import 'package:custom_splash/custom_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/theme.dart';
import 'package:freakies/screens/sign_in_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(providers: [
        StreamProvider<FirebaseUser>(
          lazy: false,
          create: (_) => FirebaseAuth.instance.onAuthStateChanged,
        ),
        ProxyProvider<FirebaseUser, Future<CurrentUser>>(
          lazy: false,
          update: (_, user, currentUser) =>
              user != null ? CurrentUser.getInstance(user) : null,
        )
      ], child: MyApp()),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: appTheme(),
        home: CustomSplash(
          backGroundColor: Color(0xFFDBE4F0),
          imagePath: 'assets/images/profile.jpg',
          logoSize: 200,
          animationEffect: 'fade-in',
          type: CustomSplashType.BackgroundProcess,
          home: SignInPage(
//                //type: PageType.signUp,
              ),
          customFunction: () async {
            var user = await Provider.of<Future<CurrentUser>>(context);
            print(user.fullName);
          },
        )
//        user == null
//            ? SignInPage(
//                //type: PageType.signUp,
//                )
//            : Home(),
        //home: EditProfile(),
        //initialRoute: '/',
        /*routes: {
          '/': (context) => Home(),
          '/post': (context) => Post(),
          '/search': (context) => Search(),
          '/notifications': (context) => Notifications(),
          '/upload': (context) => Upload(),
          '/profile': (context) => Profile()
        },*/

        );
  }
}
