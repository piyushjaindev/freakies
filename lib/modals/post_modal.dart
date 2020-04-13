import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/user_modal.dart';

class PostModal with ChangeNotifier {
  String postID;
  String ownerID;
  String postCaption;
  bool isLiked;
  String videoURL;
  String photoURL;
  String thumbnailURL;
  User owner;

  PostModal(
      {this.videoURL,
      this.ownerID,
      this.photoURL,
      this.postCaption,
      this.postID,
      this.thumbnailURL});

  factory PostModal.create(doc) {
    return PostModal(
        videoURL: doc['videoURL'],
        thumbnailURL: doc['thumbnailURL'],
        ownerID: doc['ownerID'],
        photoURL: doc['photoURL'],
        postCaption: doc['caption'],
        postID: doc['postID']);
  }

  static Future<PostModal> getInstance(doc, String cid) async {
    DocumentSnapshot documentSnapshot = await PostService().getPostData(doc);
    PostModal post = PostModal.create(documentSnapshot.data);
    post.owner = await User.getInstance(uid: post.ownerID, cid: cid);
    post.isLiked = await PostService().checkAlreadyLiked(post, cid);
    return post;
  }

  Future<void> addComment(String comment, CurrentUser user) async {
    await PostService().postComment(comment, this, user);
  }

  Future<void> updateLike(String cid) async {
    isLiked = !isLiked;
    await PostService().manageLikes(this, cid);
    notifyListeners();
  }
}
