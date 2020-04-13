import 'package:flutter/material.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:provider/provider.dart';

class ProfileBioCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return PageView(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FollowText(
                    number: user.followings,
                    text: 'following',
                  ),
                  Consumer<User>(
                    builder: (_, user, __) => FollowText(
                      number: user.followers,
                      text: 'followers',
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  width: 10.0,
                  height: 10.0,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor,
                  ),
                  width: 5.0,
                  height: 5.0,
                ),
              ],
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Bio", style: Theme.of(context).textTheme.subhead),
                  Text(
                    user.bio,
                    style: Theme.of(context).textTheme.subtitle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor,
                  ),
                  width: 5.0,
                  height: 5.0,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  width: 10.0,
                  height: 10.0,
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}

class FollowText extends StatelessWidget {
  int number;
  String text;
  FollowText({this.number, this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          number.toString(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 15.0,
          ),
        )
      ],
    );
  }
}
