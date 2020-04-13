import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:provider/provider.dart';

import 'video_pageview.dart';
//import 'home.dart';

class Post extends StatelessWidget {
  //TabController tabBarController;

//  final allPostRef = Firestore.instance.collection('allPosts');
//  final postRef = Firestore.instance.collection('posts');
//
//  fetchTimelinePost() async {
//    List<PostModal> postsLists = [];
//    QuerySnapshot snapshot = await timelinePostRef
//        .orderBy('timestamp', descending: true)
//        .getDocuments();
//    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
//      final doc = documentSnapshot.data;
//      final document = await postRef
//          .document(doc['ownerID'])
//          .collection('postData')
//          .document(doc['postID'])
//          .get();
//      postsLists.add(PostModal.create(document.data));
//    }
//    return postsLists;
//  }

//  fetchPopularPosts() async {
//    List<PostModal> postsLists = [];
//    QuerySnapshot snapshot =
//        await allPostRef.orderBy('timestamp', descending: true).getDocuments();
////    await snapshot.documents.forEach((documentSnapshot) async {
////      final doc = documentSnapshot.data;
////      final document = await postRef
////          .document(doc['ownerID'])
////          .collection('postData')
////          .document(doc['postID'])
////          .get();
////      postsLists.add(PostModal.create(document.data));
////    });
//    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
//      final doc = documentSnapshot.data;
//      final document = await postRef
//          .document(doc['ownerID'])
//          .collection('postData')
//          .document(doc['postID'])
//          .get();
//      postsLists.add(PostModal.create(document.data));
//    }
//    return postsLists;
//  }

  @override
  Widget build(BuildContext context) {
    CurrentUser user = Provider.of<CurrentUser>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: TabBar(
            //controller: tabBarController,
            isScrollable: false,
            //unselectedLabelColor: Theme.of(context).accentColor,
            //indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 4.0,
            //labelColor: Theme.of(context).primaryColor,

            tabs: <Widget>[
              Container(
                  color: Colors.transparent,
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text(
                    'Following',
                  )),
              Container(
                  color: Colors.transparent,
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text(
                    'Popular',
                  )),
            ],
          ),
          body:
//          body: Column(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              Container(
//                color: Theme.of(context).primaryColor,
//                height: 50.0,
//                child: TabBar(
//                  //controller: tabBarController,
//                  isScrollable: false,
//                  unselectedLabelColor: Theme.of(context).accentColor,
//                  indicatorColor: Theme.of(context).primaryColor,
//                  tabs: <Widget>[
//                    Text('Following'),
//                    Text('Popular'),
//                  ],
//                ),
//              ),
              TabBarView(
            physics: NeverScrollableScrollPhysics(),
            //controller: tabBarController,
            children: <Widget>[
              FutureBuilder(
                  future: user.fetchTimeline(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DocumentSnapshot> list = snapshot.data;
                      return VideoPageView(
                        postLists: list.map((snap) {
                          return PostModal.create(snap.data);
                        }).toList(),
                        currentIndex: 0,
                      );
                    }
                    return Loader();
                  }),
              FutureBuilder(
                  future: PostService().getAllPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DocumentSnapshot> list = snapshot.data;
                      return VideoPageView(
                        postLists: list.map((snap) {
                          return PostModal.create(snap.data);
                        }).toList(),
                        currentIndex: 0,
                      );
                    }
                    return Loader();
                  })
            ],
          ),
          //],
          // ),
        ),
      ),
    );
  }
}
