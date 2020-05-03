import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/size_config.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/post.dart';
import 'package:freakies/screens/profile.dart';
import 'package:freakies/screens/search.dart';
import 'package:freakies/screens/sign_in_page.dart';
import 'package:freakies/screens/upload_video.dart';
import 'package:freakies/screens/verify_email.dart';
import 'package:provider/provider.dart';

import 'notifications.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;
  User user = User();
  CurrentUser currentUser;
  List<Widget> stackChild;

  @override
  void initState() {
    stackChild = [
      Post(),
      Search(),
      Notifications(),
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    currentUser = Provider.of<CurrentUser>(context);
    if (currentUser.type == UserType.unverified ||
        currentUser.type == UserType.ready)
      setState(() {
        user = User.fromCurrentUser(currentUser);
      });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //currentUser = Provider.of<CurrentUser>(context);
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: [
          ...stackChild,
          Profile(
            user: user,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        //color: Colors.black,
        elevation: 8.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).accentColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showUnselectedLabels: true,
          currentIndex: pageIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text('Search')),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bell_solid),
                title: Text('Notifications')),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text('Profile')),
          ],
          onTap: (index) {
            if ([2, 3].contains(index) &&
                currentUser.type == UserType.anonymous)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInPage(
                            type: PageType.convertGuest,
                          )));
            else
              setState(() {
                pageIndex = index;
              });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentUser.type == UserType.anonymous)
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignInPage(
                          type: PageType.convertGuest,
                        )));
          else if (currentUser.type == UserType.unverified)
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => VerifyEmail()));
          else
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UploadVideo()));
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
