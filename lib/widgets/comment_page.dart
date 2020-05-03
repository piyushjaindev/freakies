import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/screens/sign_in_page.dart';
import 'package:freakies/screens/verify_email.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatelessWidget {
  final PostModal post;
  final commentsRef = Firestore.instance.collection('comments');

  CommentPage(this.post);

  @override
  Widget build(BuildContext context) {
    //PostModal post = Provider.of<PostModal>(context, listen: false);

    return Container(
      //widthFactor: 1.0,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  'Comments',
                  textAlign: TextAlign.center,
                )),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.close),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: commentsRef
                  .document(post.postID)
                  .collection('commentsData')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> list = snapshot.data.documents;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(list[index].data['dpURL']),
                        ),
                        title: Text("@${list[index].data['username']}"),
                        subtitle: Text(list[index].data['comment']),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Error fetching comments'),
                  ));
                }
                return Loader();
              },
            ),
          ),
          CommentButton(post)
        ],
      ),
    );
  }
}

class CommentButton extends StatelessWidget {
  final PostModal post;
  final TextEditingController _controller = TextEditingController();
  CommentButton(this.post);
  @override
  Widget build(BuildContext context) {
    //PostModal post = Provider.of<PostModal>(context, listen: false);
    CurrentUser user = Provider.of<CurrentUser>(context);
    return Card(
      margin: EdgeInsets.only(top: 5.0, bottom: 0, right: 0, left: 0),
      elevation: 2.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (user.type == UserType.anonymous)
            (Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Please '),
                FlatButton(
                  child: Text(
                    'login',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInPage(
                                //type: PageType.convertGuest,
                                )));
                  },
                ),
                Text(' to comment on this video.')
              ],
            ))
          else if (user.type == UserType.unverified)
            (Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Please '),
                FlatButton(
                  child: Text(
                    'verify your email',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => VerifyEmail()));
                  },
                ),
                Text(' to comment.')
              ],
            ))
          else
            (ListTile(
              //leading: Icon(Icons.comment),
              title: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                    hintText: 'Enter your comment',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        iconSize: 35.0,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          post.addComment(_controller.text, user);
                          _controller.clear();
                        } //postComment,
                        )),
              ),
            ))
        ],
      ),
    );
  }
}
