import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/screens/edit_profile.dart';
import 'package:freakies/screens/home.dart';
import 'package:freakies/screens/sign_in_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> lists;
  Widget activeWidget;
  //CurrentUser currentUser;
  @override
  void initState() {
    //currentUser = CurrentUser();
    lists = [
      Home(),
      SignInPage(),
      EditProfile(
        type: ActionType.complete,
      )
    ];
    activeWidget = lists[1];
    super.initState();
  }

//  @override
//  Widget builder(BuildContext context) {
//    //FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
//    return Scaffold(
//      body: StreamBuilder<FirebaseUser>(
//          stream: FirebaseAuth.instance.onAuthStateChanged,
//          builder: (context, snapshot) {
//            if (snapshot.hasData && snapshot.data != null) {
//              CurrentUser user =
//                  Provider.of<CurrentUser>(context, listen: false);
//              return Selector<CurrentUser, UserType>(
//                selector: (_, currentUser) => currentUser.type,
//                builder: (context, userType, _){
//                  return FutureBuilder(
//                    future: user.updateCurrentUser(snapshot.data),
//                    builder: (context, snapshot) {
//                      if (snapshot.hasData) {
//                        print('futurebuilder');
//                        CurrentUser currentUser = snapshot.data;
//                        Widget activeWidget;
//                        switch (currentUser.type) {
//                          case UserType.anonymous:
//                            activeWidget = lists[0];
//                            break;
//                          case UserType.unverified:
//                            activeWidget = lists[0];
//                            break;
//                          case UserType.invalid:
//                            activeWidget = lists[1];
//                            break;
//                          case UserType.incomplete:
//                            activeWidget = lists[2];
//                            break;
//                          case UserType.ready:
//                            activeWidget = lists[0];
//                            break;
//                          default:
//                            activeWidget = lists[1];
//                            break;
//                        }
//                        return activeWidget;
////                  return ChangeNotifierProvider.value(
////                    value: currentUser,
////                    child: activeWidget,
////                  );
//                      }
//                      return Loader();
//                    },
//                  );
//                },
//              );
//
//            }
//            return SignInPage();
//          }),
//    );
////    WidgetsBinding.instance.addPostFrameCallback((_) {
////      CurrentUser user = Provider.of<CurrentUser>(context);
//
////    });
////    return activeWidget;
////    return Consumer<CurrentUser>(builder: (_, user, __) {
////
////    });
//  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    return FutureBuilder<CurrentUser>(
      future: currentUser.updateCurrentUser(firebaseUser),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Selector<CurrentUser, UserType>(
              selector: (_, currentUser) => currentUser.type,
              builder: (context, userType, _) {
                switch (currentUser.type) {
                  case UserType.anonymous:
                    activeWidget = lists[0];
                    break;
                  case UserType.unverified:
                    activeWidget = lists[0];
                    break;
                  case UserType.invalid:
                    activeWidget = lists[1];
                    break;
                  case UserType.incomplete:
                    activeWidget = lists[2];
                    break;
                  case UserType.ready:
                    activeWidget = lists[0];
                    break;
                  default:
                    activeWidget = lists[1];
                    break;
                }
                return activeWidget;
//                  return ChangeNotifierProvider.value(
//                    value: currentUser,
//                    child: activeWidget,
//                  );
              }
              //return Loader();
//                },
//              );
//            },
              );
        }
        return activeWidget;
      },
    );
  }
}
