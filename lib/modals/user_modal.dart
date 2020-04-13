import 'package:flutter/foundation.dart';
import 'package:freakies/db/userservice.dart';

class User with ChangeNotifier {
  String fullName;
  String _username;
  String dpURL;
  String bio;
  String _userID;
  int followings;
  int followers;
  bool followed;

  User(
      {username,
      this.bio,
      this.dpURL,
      this.fullName,
      userID,
      this.followers,
      this.followings}) {
    _username = username;
    _userID = userID;
  }

  factory User.create(doc) {
    return User(
      fullName: doc['fullName'],
      username: doc['username'],
      dpURL: doc['dpURL'],
      bio: doc['bio'],
      userID: doc['id'],
    );
  }

  static Future<User> getInstance({String uid, String cid}) async {
    UserService userService = UserService();
    Map result = await userService.getUserDocument(uid);
    User user = User.create(result);
    await user.countFollow(userService);
    await user.setFollow(userService, cid);
    return user;
  }

  Future<void> countFollow(UserService userService) async {
    this.followings = await userService.followingCount(this.id);
    this.followers = await userService.followerCount(this.id);
  }

  Future<void> setFollow(UserService userService, String cid) async {
    this.followed = await userService.checkAlreadyFollowing(this.id, cid);
  }

  updateFollow(String cid) async {
    UserService().updateFollower(cid, _userID);
    followed ? followers-- : followers++;
    followed = !followed;
    notifyListeners();
  }

  String get id => _userID;
  String get username => _username;
}
