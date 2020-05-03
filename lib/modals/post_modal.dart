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
  String thumbnailURL;
  User owner;

  PostModal(
      {this.videoURL,
      this.ownerID,
      this.postCaption,
      this.postID,
      this.thumbnailURL});

  factory PostModal.create(doc) {
    return PostModal(
        videoURL: doc['videoURL'] ??
            'https://media.publit.io/file/w_720/20191230_221509.mp4?at=eyJpdiI6InJVMVZuTk4yZEJkdkFjSFZzREl0bHc9PSIsInZhbHVlIjoiT0NVWjZGRHdFa05XZUxzMk5jUWwzZVwvVDdVMTQ4MVJpZGxHSVpMNXh0KzA9IiwibWFjIjoiZjU5ODk4YmFjMjJkYTU4YTM0YTMzZjliYTMxMGEwOTU4M2Y0ZWM1NmJkMGJjMTg4ODM3ZGJjOWY5ZTM1NzNiMCJ9',
        thumbnailURL: doc['thumbnailURL'] ??
            'https://media.publit.io/file/w_150/profile-picture.jpg',
        ownerID: doc['ownerID'],
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

  @override
  bool operator ==(post) {
    return this.postID == post.postID;
  }

  @override
  int get hashCode => super.hashCode;
}
