import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/screens/profile.dart';
import 'package:freakies/widgets/comment_page.dart';
import 'package:provider/provider.dart';

class VideoIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostModal post = Provider.of<PostModal>(context, listen: false);
    CurrentUser user = Provider.of<CurrentUser>(context, listen: false);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.postCaption,
                softWrap: true,
                maxLines: 4,
                style: Theme.of(context).textTheme.subtitle.copyWith(
                      color: Color(0xFFE64926),
//              fontSize: 20.0,
                    ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                user: post.owner,
                              )));
                },
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(post.owner.dpURL),
                ),
              ),
              Consumer<PostModal>(
                builder: (_, post, child) => child,
                child: IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                  iconSize: 40.0, //isLiked ? 25.0 : 20.0,
                  //color: Colors.redAccent,
                  onPressed: () {
                    post.updateLike(user.id);
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.speaker_notes,
                ),
                iconSize: 40.0,
                //color: Colors.redAccent,
                onPressed: () {
                  showModalBottomSheet(
                      // isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return CommentPage();
                      });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                ),
                iconSize: 40.0,
                //color: Colors.redAccent,
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}
