import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/size_config.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/profile_settings.dart';
import 'package:freakies/widgets/profile_bio_carousel.dart';
import 'package:freakies/widgets/profile_display_videos.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  final User user;
  Profile({this.user});

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return currentUser.type != UserType.anonymous ||
            currentUser.type != UserType.invalid
        ? ChangeNotifierProvider.value(
            value: user,
            child: Scaffold(
              appBar: AppBar(
                //backgroundColor: Colors.green,
                title: Text(
                  "${user.username}\'s Profile",
                ),
                actions: <Widget>[
                  user.id != currentUser.id
                      ? Text('')
                      : IconButton(
                          icon: Icon(
                            Icons.settings,
                          ),
                          iconSize: 35.0,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileSettings(
                                        //currentUser: widget.currentUser,
                                        )));
                          },
                        )
                ],
              ),
              //backgroundColor: Colors.black,
              body: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
//              Image(
//                image: AssetImage("assets/images/profile.jpg"),
//                width: double.infinity,
//                height: SizeConfig.mainHeight * 0.42,
//                fit: BoxFit.cover,
//              ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.mainHeight * 0.06,
                            left: SizeConfig.mainWidth * 0.18,
                            bottom: 0.0,
                            right: 0.0),
                        child: Container(
                          margin: EdgeInsets.all(0.0),
                          width: SizeConfig.mainWidth * 0.65,
                          height: SizeConfig.mainHeight * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color:
                                  Colors.white, //Colors.white.withOpacity(0.7),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    spreadRadius: 0.0,
                                    blurRadius: 2.0),
                              ]),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 15.0,
                                bottom: 5.0,
                                left: 10.0,
                                right: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      width: 150.0,
                                      height: 30.0,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          user.fullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle,
                                          //color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 150.0,
                                      height: 30.0,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                        child: Text('@${user.username}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subhead),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.mainHeight * 0.04,
                                ),
                                ProfileBioCarousel()
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.mainWidth * 0.06,
                            top: SizeConfig.mainHeight * 0.02,
                            bottom: 0,
                            right: 0),
                        child: CircleAvatar(
                          radius: SizeConfig.mainWidth * 0.15,
                          backgroundImage: NetworkImage(user.dpURL),
                        ),
                      ),
                      currentUser.id == user.id ||
                              currentUser.type == UserType.anonymous
                          ? Text('')
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: SizeConfig.mainHeight * 0.17,
                                  left: SizeConfig.mainWidth * 0.78),
                              child: RawMaterialButton(
                                shape: CircleBorder(),
                                fillColor: Theme.of(context).primaryColor,
                                constraints: BoxConstraints.tightFor(
                                    width: SizeConfig.mainWidth * 0.15,
                                    height: SizeConfig.mainWidth * 0.15),
                                elevation: 6.0,
                                child: Consumer<User>(
                                  builder: (_, user, __) => Icon(
                                    user.followed ? Icons.check : Icons.add,
                                    size: SizeConfig.mainWidth * 0.12,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  user.updateFollow(currentUser.id);
                                },
                              ),
                            ),
                    ],
                  ),
                  FittedBox(
                    //fit: BoxFit.fitHeight,
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      width: SizeConfig.mainWidth,
                      height: SizeConfig.mainHeight * 0.40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              spreadRadius: 0,
                              blurRadius: 5.0,
                              offset: Offset(3, 3),
                            ),
                          ]),
                      child: ProfileDisplayVideos(),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
