import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:freakies/widgets/notification_tile.dart';
import 'package:provider/provider.dart';

class Notifications extends StatelessWidget {
  final CollectionReference notificationRef =
      Firestore.instance.collection('notifications');

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder(
        stream: notificationRef
            .document(currentUser.id)
            .collection('feeds')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> list = snapshot.data.documents;
            return ListView.separated(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                    future: User.getInstance(
                        uid: list[index].data['userId'], cid: currentUser.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        User user = snapshot.data;
                        if (list[index].data['type'] == 'follow') {
                          return NotificationTile(
                            user: user,
                            type: 'follow',
                          );
                        }
                        return FutureBuilder(
                          future: PostModal.getInstance(
                              list[index].data, currentUser.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              PostModal post = snapshot.data;
                              return NotificationTile(
                                user: user,
                                type: list[index].data['type'],
                                comment: list[index].data['comment'],
                                post: post,
                              );
                            }
                            return Container();
                          },
                        );
                      }
                      return Container(
                        height: 100,
                        color: Colors.white,
                        width: double.infinity,
                      );
                    });
              },
              separatorBuilder: (context, index) => Divider(
                thickness: 1.0,
                color: Colors.black,
                endIndent: 20.0,
                indent: 20.0,
                height: 3.0,
              ),
            );
          }
          return Loader();
        },
      ),
    );
  }
}
