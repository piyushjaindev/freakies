import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/size_config.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/post.dart';
import 'package:freakies/screens/profile.dart';
import 'package:freakies/screens/search.dart';
import 'package:freakies/screens/upload_video.dart';
import 'package:freakies/widgets/loader.dart';

import 'notifications.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;
  int pageIndex = 0;
  User currentUser;
  FirebaseUser user;

//  void currentUserAssigner() async {
//    currentUser = await createUserObject(user.uid.toString());
//    if (user.email == null)
//      currentUser.emailVerified = true;
//    else
//      currentUser.emailVerified = user.isEmailVerified;
//    Timer(Duration(milliseconds: 500), () {
//      pageController.jumpToPage(0);
//    });
//    //pageController.jumpToPage(0);
//  }

  @override
  void initState() {
//    user = Provider.of<FirebaseUser>(context);
//    currentUser = User(userID: user.uid);
//    if (user.isAnonymous)
//      currentUser = User(isAnonymous: true, userID: user.uid);
//    else
//      currentUserAssigner();
    pageController = PageController(initialPage: 0);
    super.initState();
    //fetchPosts();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Color setColor(int x) {
    if (x == pageIndex)
      return Theme.of(context).primaryColor;
    else
      return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Post(),
          Search(),
          Notifications(),
          Profile(
            user: currentUser,
          ),
          UploadVideo(),
          Loader(),
        ],
        controller: pageController,
        onPageChanged: (pageIn) {
          setState(() {
            pageIndex = pageIn;
          });
        },
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        //color: Colors.black,
        elevation: 15.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.whatshot),
                  color: setColor(0),
                  onPressed: () {
                    pageController.jumpToPage(0);
//                        setState(() {
//                        });
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: IconButton(
                  color: setColor(1),
                  icon: Icon(Icons.search),
                  onPressed: () {
                    pageController.jumpToPage(1);
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: IconButton(
                  color: setColor(2),
                  icon: Icon(CupertinoIcons.bell_solid),
                  onPressed: () {
//                    currentUser.isAnonymous
//                        ? Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => SignInPage(
//                                      type: PageType.convertGuest,
//                                    )))
                    pageController.jumpToPage(2);
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  color: setColor(3),
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
//                    currentUser.isAnonymous
//                        ? Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => SignInPage(
//                                      type: PageType.convertGuest,
//                                    )))
                    pageController.jumpToPage(3);
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.push(context, MaterialPageRoute(builder: (context) => Upload()));
//          if (currentUser.isAnonymous)
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => SignInPage(
//                          type: PageType.convertGuest,
//                        )));
////              else if(!widget.currentUser.emailVerified)
////                Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmail()));
//          else
          pageController.jumpToPage(4);
          //Navigator.push(context, MaterialPageRoute(builder: (context) => UploadVideo()));
          //showVideoDialog(context);
        },
        //backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
