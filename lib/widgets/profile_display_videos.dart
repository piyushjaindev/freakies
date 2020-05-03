import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/modals/currentuser.dart';
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
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20.0, top: 10.0),
          height: 40.0,
          //alignment: Alignment.center,
          child: Text('All Videos'),
//            child: TabBar(
//              tabs: <Widget>[Text('Popular Videos'), Text('All Videos')],
//            ),
        ),
        Expanded(
          child: FutureBuilder(
              future: user.id == currentUser.id
                  ? currentUser.fetchAllVideos()
                  : PostService().profileAllPosts(user.id),
              builder: (context, snapshot) {
                List<PostModal> posts;
//                      if (snapshot.connectionState == ConnectionState.waiting)
//                        return Loader();
                if (snapshot.hasError) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Error fetching videos'),
                  ));
                  return Text('');
                } else if (snapshot.hasData) {
                  posts = user.id == currentUser.id
                      ? Provider.of<CurrentUser>(context).posts
                      : snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GridView.builder(
                      itemCount: posts.length,
                      padding: EdgeInsets.all(15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
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
                                          isOwner: user.id == currentUser.id,
                                        )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          posts[index].thumbnailURL),
                                      fit: BoxFit.fill)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return Loader();
              }),
//            child: TabBarView(
//              physics: NeverScrollableScrollPhysics(),
//              children: <Widget>[
//                FutureBuilder(
//                    future: PostService().profilePopularPosts(user.id),
//                    builder: (context, snapshot) {
//                      List<PostModal> posts;
////                      if (snapshot.connectionState == ConnectionState.waiting)
////                        return Loader();
//                      if (snapshot.hasError) {
//                        Scaffold.of(context).showSnackBar(SnackBar(
//                          content: Text('Error fetching videos'),
//                        ));
//                        return Text('');
//                      } else if (snapshot.hasData) {
//                        posts = snapshot.data;
//                        return Padding(
//                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                          child: ListView.builder(
//                              itemExtent: 150,
//                              shrinkWrap: true,
//                              itemCount: posts.length,
//                              scrollDirection: Axis.horizontal,
//                              padding: EdgeInsets.symmetric(
//                                  horizontal: 5.0, vertical: 10.0),
//                              itemBuilder: (context, index) {
//                                return GestureDetector(
//                                  onTap: () {
//                                    Navigator.push(
//                                        context,
//                                        MaterialPageRoute(
//                                            builder: (context) => VideoPageView(
//                                                  postLists: posts,
//                                                  currentIndex: posts
//                                                      .indexOf(posts[index]),
//                                                )));
//                                  },
//                                  child: Padding(
//                                    padding: const EdgeInsets.only(right: 5.0),
//                                    child: ClipRRect(
//                                      borderRadius: BorderRadius.circular(5.0),
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            image: DecorationImage(
//                                                image: NetworkImage(
//                                                    posts[index].thumbnailURL),
//                                                fit: BoxFit.fill)),
//                                      ),
//                                    ),
//                                  ),
//                                );
//                              }),
//                        );
//                      }
//                      return Loader();
//                    }),
//                FutureBuilder(
//                    future: PostService().profileAllPosts(user.id),
//                    builder: (context, snapshot) {
//                      List<PostModal> posts;
////                      if (snapshot.connectionState == ConnectionState.waiting)
////                        return Loader();
//                      if (snapshot.hasError) {
//                        Scaffold.of(context).showSnackBar(SnackBar(
//                          content: Text('Error fetching videos'),
//                        ));
//                        return Text('');
//                      } else if (snapshot.hasData) {
//                        posts = snapshot.data;
//                        return Padding(
//                          padding: const EdgeInsets.only(bottom: 10.0),
//                          child: GridView.builder(
//                            itemCount: posts.length,
//                            padding: EdgeInsets.all(15),
//                            scrollDirection: Axis.vertical,
//                            shrinkWrap: true,
//                            gridDelegate:
//                                SliverGridDelegateWithFixedCrossAxisCount(
//                                    crossAxisCount: 3,
//                                    mainAxisSpacing: 5.0,
//                                    crossAxisSpacing: 5.0,
//                                    childAspectRatio: 0.8),
//                            itemBuilder: (context, index) {
//                              return GestureDetector(
//                                onTap: () {
//                                  Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (context) => VideoPageView(
//                                                postLists: posts,
//                                                currentIndex:
//                                                    posts.indexOf(posts[index]),
//                                              )));
//                                },
//                                child: Container(
//                                  decoration: BoxDecoration(
//                                      image: DecorationImage(
//                                          image: NetworkImage(
//                                              posts[index].thumbnailURL),
//                                          fit: BoxFit.fill)),
//                                ),
//                              );
//                            },
//                          ),
//                        );
//                      }
//                      return Loader();
//                    })
//              ],
//            ),
        )
      ],
    );
  }
}
