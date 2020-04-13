import 'package:flutter/material.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/profile.dart';
import 'package:freakies/screens/video_pageview.dart';

class NotificationTile extends StatelessWidget {
  final User user;
  final String type;
  final String comment;
  final PostModal post;

  String getTitle(String type) {
    String title;
    switch (type) {
      case 'like':
        title = 'liked your post';
        break;
      case 'comment':
        title = 'commented on your post';
        break;
      case 'follow':
        title = 'started following you';
        break;
      case 'newpost':
        title = 'added a new post';
        break;
    }
    return title;
  }

  NotificationTile({this.user, this.type, this.comment, this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                        user: user,
                      )));
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.dpURL),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  maxLines: 2,
                  text: TextSpan(
                      text: '@${user.username} ',
                      style: Theme.of(context).textTheme.subhead,
                      children: [
                        TextSpan(
                            text: getTitle(type),
                            style: Theme.of(context).textTheme.body1)
                      ]),
                ),
                SizedBox(height: 5.0),
                if (comment.isNotEmpty || comment != null)
                  (Text('\'$comment\'')),
              ],
            ),
          ),
          if (post != null)
            (GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoPageView(
                          postLists: [post],
                        )));
              },
              child: FittedBox(
                child: Container(
                  width: 70.0,
                  height: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(post.thumbnailURL),
                          fit: BoxFit.fill)),
                ),
              ),
            ))
        ],
      ),
    );
  }
}
