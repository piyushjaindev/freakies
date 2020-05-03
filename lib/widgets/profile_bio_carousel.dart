import 'package:flutter/material.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:provider/provider.dart';

class ProfileBioCarousel extends StatefulWidget {
  @override
  _ProfileBioCarouselState createState() => _ProfileBioCarouselState();
}

class _ProfileBioCarouselState extends State<ProfileBioCarousel> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return LimitedBox(
      //maxWidth: 460,
      maxHeight: 100,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              onPageChanged: (index) {
                setState(() {
                  pageIndex = index;
                });
              },
              children: <Widget>[
                Row(
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
                Column(
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
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pageIndex == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                ),
                width: pageIndex * -3 + 7.0,
                height: pageIndex * -3 + 7.0,
              ),
              SizedBox(
                width: 5.0,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pageIndex == 1
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                ),
                width: pageIndex * 3 + 4.0,
                height: pageIndex * 3 + 4.0,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class FollowText extends StatelessWidget {
  final int number;
  final String text;
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
