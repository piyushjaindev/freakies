import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:uuid/uuid.dart';

class PostService {
  final postRef = Firestore.instance.collection('posts');
  final commentsRef = Firestore.instance.collection('comments');

  Future<List<DocumentSnapshot>> fetchTimelinePost(String id) async {
    CollectionReference timelinePostRef = Firestore.instance
        .collection('timeline')
        .document(id)
        .collection('posts');
    QuerySnapshot snapshot = await timelinePostRef
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<DocumentSnapshot> list = [];

    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      DocumentSnapshot snap = await getPostData(documentSnapshot.data);
      list.add(snap);
    }
    return list;
  }

  Future<List<DocumentSnapshot>> getAllPosts() async {
    CollectionReference allPostRef = Firestore.instance.collection('allPosts');
    QuerySnapshot snapshot =
        await allPostRef.orderBy('timestamp', descending: true).getDocuments();

    List<DocumentSnapshot> list = [];

    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      DocumentSnapshot snap = await getPostData(documentSnapshot.data);
      list.add(snap);
    }
    return list;
  }

  Future<DocumentSnapshot> getPostData(doc) async {
    return await postRef
        .document(doc['ownerID'])
        .collection('postData')
        .document(doc['postID'])
        .get();
  }

  void postComment(String comment, PostModal post, CurrentUser user) {
    if (comment.isEmpty ||
        comment.length < 1 ||
        comment == null ||
        comment == '')
      return;
    else {
      var randomID = Uuid().v4();
      try {
        commentsRef
            .document(post.postID)
            .collection('commentsData')
            .document(randomID)
            .setData({
          'commentID': randomID,
          'timestamp': DateTime.now(),
          'comment': comment,
          'postID': post.postID,
          'ownerID': post.ownerID,
          'commenterID': user.id,
          'username': user.username,
          'dpURL': user.dpURL
        });
      } catch (e) {
        throw e;
//        Scaffold.of(context).showSnackBar(SnackBar(
//          content: Text('Error in submitting comment'),
//        ));
      }
      //_commentTextController.clear();
    }
  }

  Future<bool> checkAlreadyLiked(PostModal post, String cid) async {
    DocumentSnapshot documentSnapshot = await postRef
        .document(post.ownerID)
        .collection('postData')
        .document(post.postID)
        .collection('metaData')
        .document(cid)
        .get();
    return documentSnapshot.exists;
  }

  manageLikes(PostModal post, String cid) async {
    try {
      DocumentReference documentReference = postRef
          .document(post.ownerID)
          .collection('postData')
          .document(post.postID)
          .collection('metaData')
          .document(cid);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        await documentReference.delete();
      } else {
        documentReference.setData({});
      }
    } catch (e) {
      throw e;
//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text('Something went wrong'),
//      ));
    }
  }
}
