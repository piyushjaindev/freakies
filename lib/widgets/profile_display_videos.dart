import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/video_pageview.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:provider/provider.dart';

class ProfileDisplayVideos extends StatelessWidget {
  final postRef = Firestore.instance.collection('posts');
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: <Widget>[Text('Popular Videos'), Text('All Videos')],
          ),
          TabBarView(
            children: <Widget>[
              FutureBuilder(
                  future: postRef
                      .document(user.id)
                      .collection('postData')
                      .orderBy('views', descending: true)
                      .limit(5)
                      .getDocuments(),
                  builder: (context, snapshot) {
                    List<PostModal> posts = [];
//                      if (snapshot.connectionState == ConnectionState.waiting)
//                        return Loader();
                    if (snapshot.hasError) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Error fetching videos'),
                      ));
                      return Text('');
                    } else if (snapshot.hasData) {
                      snapshot.data.documents.forEach((documentSnapshot) {
                        final doc = documentSnapshot.data;
                        PostModal postObj = PostModal.create(doc);
                        posts.add(postObj);
                      });
                      return ListView.builder(
                          itemCount: posts.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VideoPageView(
                                              postLists: posts,
                                              currentIndex:
                                                  posts.indexOf(posts[index]),
                                            )));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              posts[index].thumbnailURL),
                                          fit: BoxFit.fill)),
                                ),
                              ),
                            );
                          });
                    }
                    return Loader();
                  }),
              StreamBuilder(
                  stream: postRef
                      .document(user.id)
                      .collection('postData')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<PostModal> posts = [];
//                      if (snapshot.connectionState == ConnectionState.waiting)
//                        return Loader();
                    if (snapshot.hasError) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Error fetching videos'),
                      ));
                      return Text('');
                    } else if (snapshot.hasData) {
                      snapshot.data.documents.forEach((documentSnapshot) {
                        final doc = documentSnapshot.data;
                        PostModal postObj = PostModal.create(doc);
                        posts.add(postObj);
                      });
                      return GridView.builder(
                        itemCount: posts.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2.0,
                            crossAxisSpacing: 2.0,
                            childAspectRatio: 0.8),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoPageView(
                                            postLists: posts,
                                            currentIndex:
                                                posts.indexOf(posts[index]),
                                          )));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          posts[index].thumbnailURL),
                                      fit: BoxFit.fill)),
                            ),
                          );
                        },
                      );
                    }
                    return Loader();
                  })
            ],
          )
        ],
      ),
    );
  }
}
