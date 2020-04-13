import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/db/userservice.dart';

enum UserType { anonymous, unverified, invalid, incomplete, ready }

class CurrentUser {
  String fullName;
  String _username;
  String dpURL;
  String bio;
  String _userID;
  String _email;
  int followings;
  int followers;
  UserType _type;

  CurrentUser(
      {String username,
      this.bio,
      this.dpURL,
      this.fullName,
      String userID,
      String email,
      UserType type = UserType.ready}) {
    _userID = userID;
    _email = email;
    _username = username;
    _type = type;
  }

  static Future<CurrentUser> getInstance(FirebaseUser firebaseUser) async {
    CurrentUser user;
    if (firebaseUser == null)
      user = CurrentUser(type: UserType.invalid);
    else if (firebaseUser.isAnonymous)
      user = CurrentUser(type: UserType.anonymous);
    else {
      UserService userService = UserService();
      Map result = await userService.getUserDocument(firebaseUser.uid);
      if (result.isEmpty || result == null)
        user = CurrentUser(type: UserType.incomplete);
      else {
        CurrentUser user = CurrentUser.create(result);
        user.followings = await userService.followingCount(firebaseUser.uid);
        user.followers = await userService.followerCount(firebaseUser.uid);
        if (!firebaseUser.isEmailVerified) user._type = UserType.unverified;
      }
    }
    return user;
  }

  factory CurrentUser.create(doc) {
    return CurrentUser(
        fullName: doc['fullName'],
        username: doc['username'],
        dpURL: doc['dpURL'],
        bio: doc['bio'],
        email: doc['email'],
        userID: doc['id']);
  }

  Future<void> createUserDocument(doc) async {
    fullName = doc['fullName'];
    _username = doc['username'];
    dpURL = doc['dpURL'];
    bio = doc['bio'];
    _email = doc['email'];
    _userID = doc['userID'];
    await UserService().setUser(this);
  }

  Future<void> updateUserDocument(doc) async {
    fullName = doc['fullName'];
    _username = doc['username'];
    dpURL = doc['dpURL'];
    bio = doc['bio'];
    await UserService().updateUser(this);
  }

  Future<List<DocumentSnapshot>> fetchTimeline() async {
    return await PostService().fetchTimelinePost(_userID);
  }

  String get id => _userID;
  String get username => _username;
  String get email => _email;
  UserType get type => _type;
}
