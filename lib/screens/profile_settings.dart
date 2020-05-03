import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/screens/change_password.dart';
import 'package:freakies/screens/edit_profile.dart';
import 'package:provider/provider.dart';

class ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hello,',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Consumer<CurrentUser>(
                          builder: (_, currentUser, __) => Text(
                                currentUser.fullName,
                                style: Theme.of(context).textTheme.body2,
                              )),
                    ],
                  ),
                  Consumer<CurrentUser>(
                    builder: (_, currentUser, __) => CircleAvatar(
                      radius: 40.0,
                      backgroundImage: NetworkImage(currentUser.dpURL),
                    ),
                  ),
//                      SizedBox(
//                        width: 30.0,
//                      ),
                ],
              ),
            ),
            //SizedBox(height: 15.0,),
            SettingOption(
              textToShow: 'Edit Profile',
              route: EditProfile(
                type: ActionType.edit,
                // uid: currentUser.userID,
              ),
            ),
            //SizedBox(height: 5.0,),
            SettingOption(
              textToShow: 'Change Password',
              route: ChangePassword(),
            ),
            //SizedBox(height: 5.0,),
            SettingOption(
              textToShow: 'Terms & Conditions',
            ),
            //SizedBox(height: 5.0,),
            SettingOption(textToShow: 'Privacy Policy'),
            SizedBox(
              height: 20.0,
            ),
            FlatButton(
              child: Text(
                'Logout',
                style: Theme.of(context)
                    .textTheme
                    .body2
                    .copyWith(color: Color(0xFFE64926)),
              ),
              onPressed: () async {
                final _auth = FirebaseAuth.instance;
                await _auth.signOut();
                Navigator.of(context).pop();
//                Navigator.pushAndRemoveUntil(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => SignInPage(
//                            //type: PageType.signIn,
//                            )),
//                    (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingOption extends StatelessWidget {
  final String textToShow;
  final route;

  SettingOption({
    this.textToShow,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => route));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Text(textToShow),
      ),
    );
  }
}
