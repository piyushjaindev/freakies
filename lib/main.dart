import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/theme.dart';
import 'package:freakies/screens/homepage.dart';
import 'package:provider/provider.dart';

import 'modals/currentuser.dart';

void main() => runApp(
      MultiProvider(providers: [
        StreamProvider<FirebaseUser>(
          lazy: false,
          //initialData: FirebaseAuth.instance.currentUser(),
          create: (_) => FirebaseAuth.instance.onAuthStateChanged,
        ),
        ChangeNotifierProvider<CurrentUser>(
          lazy: false,
          create: (_) => CurrentUser(),
        ),
//        ProxyProvider<FirebaseUser, void>(
//            lazy: false,
//            //create: (_) => CurrentUser(),
//            update: (context, user, _) async {
//              CurrentUser currentUser = Provider.of(context);
//              await currentUser.updateCurrentUser(user);
//            }),
      ], child: MyApp()),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final Future<CurrentUser> user = Provider.of<Future<CurrentUser>>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme(),
      home: HomePage(),
    );
//    return StreamBuilder<FirebaseUser>(
//      stream: FirebaseAuth.instance.onAuthStateChanged,
//      builder: (context, snapshot) {
//        if (snapshot.hasData && snapshot.data != null) {
//          print('logged in');
//          return MaterialApp(
//            title: 'Flutter Demo',
//            theme: appTheme(),
//            home: HomePage(),
//          );
//        }
//        print('not logged in');
//        return MaterialApp(
//          title: 'Flutter Demo',
//          theme: appTheme(),
//          home: SignInPage(),
//        );
//      },
//    );
  }
}
