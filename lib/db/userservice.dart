import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/user_modal.dart';

enum ActionType { edit, complete }

class UserService {
  final followingRef = Firestore.instance.collection('following');
  final followerRef = Firestore.instance.collection('follower');
  final userRef = Firestore.instance.collection('users');
  final notificationRef = Firestore.instance.collection('notifications');

  Future<Map<String, dynamic>> getUserDocument(String id) async {
    DocumentSnapshot documentSnapshot = await userRef.document(id).get();
    return documentSnapshot.data;
  }

  Future<bool> checkUser(String docID) async {
    try {
      final doc = await userRef.document(docID).get();
      if (doc.exists)
        return true;
      else
        return false;
    } catch (e) {
      throw e;
    }
  }

  Future<int> followingCount(String id) async {
    try {
      QuerySnapshot followingSnapshot = await followingRef
          .document(id)
          .collection('userFollowing')
          .getDocuments();

      return followingSnapshot.documents.length;
    } catch (e) {
      throw e;
    }
  }

  Future<int> followerCount(String id) async {
    try {
      QuerySnapshot followerSnapshot = await followerRef
          .document(id)
          .collection('userFollowers')
          .getDocuments();

      return followerSnapshot.documents.length;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> validateUsername(String username) async {
    try {
      final userRef = Firestore.instance.collection('users');
      final querySnapshot = await userRef
          .where('username', isEqualTo: username)
          .limit(1)
          .getDocuments();
      final doc = querySnapshot.documents;
      if (doc.length < 1)
        return true;
      else
        return false;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> checkAlreadyFollowing(String id, String cid) async {
    try {
      DocumentSnapshot documentSnapshot = await followingRef
          .document(cid)
          .collection('userFollowing')
          .document(id)
          .get();
      return documentSnapshot.exists;
    } catch (e) {
      throw e;
    }
  }

  void updateFollower(String cid, String id) async {
    try {
      DocumentReference documentReference =
          followingRef.document(cid).collection('userFollowing').document(id);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        documentReference.delete();
        followerRef
            .document(id)
            .collection('userFollowers')
            .document(cid)
            .delete();
      } else {
        documentReference.setData({'id': id});
        followerRef
            .document(id)
            .collection('userFollowers')
            .document(cid)
            .setData({'id': cid, 'timestamp': DateTime.now()});
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> setUser(CurrentUser user) {
    try {
      userRef.document(user.id).setData({
        'fullName': user.fullName,
        'name': user.fullName.toLowerCase(),
        'username': user.username,
        'bio': user.bio,
        'id': user.id,
        'email': user.email,
        'timestamp': DateTime.now(),
        'dpURL': user.dpURL
//            'dpURL': _dpFile != null
//                ? await uploadImage(firebaseUser.uid)
//                : 'https://firebasestorage.googleapis.com/v0/b/freakies-f9a09.appspot.com/o/profile.jpg?alt=media&token=1857b905-be18-41d9-ac2b-4368d741bddc',
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUser(CurrentUser user) async {
    try {
      //FirebaseUser firebaseUser = await _auth.currentUser();
      //if (type == ActionType.edit) {
//          _dpFile = dpChanged ? await compressImage(
//              bytes: _dpFile.readAsBytesSync(), quality: 85) : null;
      userRef.document(user.id).updateData({
        'fullName': user.fullName,
        'name': user.fullName.toLowerCase(),
        'bio': user.bio,
        'dpURL': user.dpURL
      });
      //Navigator.pop(context, currentUser: widget.currentUser);
      //}
    } catch (e) {
      throw e;
      //  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error updating user details'),));
    }
  }

  Future<List<User>> searchUsers({String searchTerm, String cid}) async {
    List<User> userList = [];
    Map<String, DocumentSnapshot> documentMap = {};
    try {
      final usernameSnapshot = await userRef
          .orderBy('username')
          .startAt([searchTerm]).endAt([searchTerm + '\uf8ff']).getDocuments();
      usernameSnapshot.documents.forEach((document) {
        documentMap.putIfAbsent(document.documentID, () => document);
//
      });
      final nameSnapshot = await userRef
          .orderBy('name')
          .startAt([searchTerm]).endAt([searchTerm + '\uf8ff']).getDocuments();
      nameSnapshot.documents.forEach((document) {
        documentMap.putIfAbsent(document.documentID, () => document);
      });

      //return documentMap;
      for (DocumentSnapshot doc in documentMap.values) {
        User user = User.create(doc.data);
        await user.countFollow(this);
        await user.setFollow(this, cid);
        userList.add(user);
      }
      return userList;
    } catch (e) {
      throw e;
    }
  }
}
