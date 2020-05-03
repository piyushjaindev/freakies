import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/db/userservice.dart';
import 'package:freakies/modals/post_modal.dart';

enum UserType { anonymous, unverified, invalid, incomplete, ready }

class CurrentUser with ChangeNotifier {
  String fullName;
  String _username;
  String dpURL;
  String bio;
  String _userID;
  String _email;
  int followings;
  int followers;
  UserType _type;
  List<PostModal> posts;
  //static CurrentUser currentUser = CurrentUser();

//  factory CurrentUser() {
//    if (currentUser == null) {
//      currentUser = CurrentUser._private(UserType.invalid);
//    }
//    return currentUser;
//  }
  CurrentUser() {
    _type = UserType.invalid;
  }

//  CurrentUser._private(UserType type) {
//    _type = type;
//    //notifyListeners();
//  }

  Future<CurrentUser> updateCurrentUser(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      if (this.type != UserType.invalid) type = UserType.invalid;
    } else if (firebaseUser.isAnonymous) {
      if (this._type != UserType.anonymous) {
        this._userID = firebaseUser.uid;
        type = UserType.anonymous;
      }
    } else {
      UserService userService = UserService();
      Map<String, dynamic> doc =
          await userService.getUserDocument(firebaseUser.uid);
      if (doc == null) {
        if (this._type != UserType.incomplete) {
          this._userID = firebaseUser.uid;
          type = UserType.incomplete;
        }
      } else {
        UserType t = UserType.ready;
        if (!firebaseUser.isEmailVerified) t = UserType.unverified;
        this.fullName = doc['fullName'];
        this._username = doc['username'];
        this.dpURL = doc['dpURL'];
        this.bio = doc['bio'];
        this._email = doc['email'];
        this._userID = doc['id'];
        this.followings = await userService.followingCount(firebaseUser.uid);
        this.followers = await userService.followerCount(firebaseUser.uid);
        type = t;
      }
    }
    return this;
  }

//  CurrentUser(
//      {String username,
//      this.bio,
//      this.dpURL,
//      this.fullName,
//      String userID,
//      String email,
//      UserType type = UserType.ready}) {
//    _userID = userID;
//    _email = email;
//    _username = username;
//    _type = type;
//    notifyListeners();
//  }

//  static Future<CurrentUser> getInstance(FirebaseUser firebaseUser) async {
//    //CurrentUser user;
//    if (firebaseUser == null)
//      return CurrentUser._private(UserType.invalid);
//    else if (firebaseUser.isAnonymous)
//      return CurrentUser._private(UserType.anonymous);
//    else {
//      UserService userService = UserService();
//      Map result = await userService.getUserDocument(firebaseUser.uid);
//      if (result == null)
//        return CurrentUser._private(UserType.incomplete);
//      else {
//        UserType t = UserType.ready;
//        if (!firebaseUser.isEmailVerified) t = UserType.unverified;
//        CurrentUser user = CurrentUser._create(result, t);
//        user.followings = await userService.followingCount(firebaseUser.uid);
//        user.followers = await userService.followerCount(firebaseUser.uid);
//        return user;
//      }
//    }
//  }

//
//  CurrentUser._create(doc, UserType type) {
//    fullName = doc['fullName'];
//    _username = doc['username'];
//    dpURL = doc['dpURL'];
//    bio = doc['bio'];
//    _email = doc['email'];
//    _userID = doc['id'];
//    _type = type ?? UserType.ready;
//    //notifyListeners();
//  }

  Future<void> createUserDocument(doc, bool emailVerified) async {
    fullName = doc['fullName'];
    _username = doc['username'];
    dpURL = doc['dpURL'];
    bio = doc['bio'];
    _email = doc['email'];
    _userID = doc['id'];
    followings = 0;
    followers = 0;
    _type = emailVerified ? UserType.ready : UserType.unverified;
    await UserService().setUser(this);
    notifyListeners();
  }

  Future<void> updateUserDocument(doc) async {
    fullName = doc['fullName'];
    _username = doc['username'];
    dpURL = doc['dpURL'];
    bio = doc['bio'];
    await UserService().updateUser(this);
    notifyListeners();
  }

  Future<List<PostModal>> fetchTimeline() async {
    return await PostService().fetchTimelinePost(_userID);
  }

  Future<List<PostModal>> fetchAllVideos() async {
    posts = await PostService().profileAllPosts(_userID);
    return posts;
  }

  Future<void> deleteVideo(PostModal post) async {
    await PostService().deleteProfileVideo(_userID, post.postID);

    if (posts.length > 1)
      posts.remove(post);
    else
      posts.clear();
    notifyListeners();
  }

  String get id => _userID;
  String get username => _username;
  String get email => _email;
  UserType get type => _type;

  set type(UserType type) {
    _type = type;
    notifyListeners();
  }
}
