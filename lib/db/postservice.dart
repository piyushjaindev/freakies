import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:uuid/uuid.dart';

class PostService {
  final postRef = Firestore.instance.collection('posts');
  final commentsRef = Firestore.instance.collection('comments');

  Future<List<PostModal>> fetchTimelinePost(String id) async {
    CollectionReference timelinePostRef = Firestore.instance
        .collection('timeline')
        .document(id)
        .collection('posts');
    QuerySnapshot snapshot = await timelinePostRef
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<PostModal> list = [];

    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      PostModal post = await PostModal.getInstance(documentSnapshot.data, id);
      list.add(post);
    }
    return list;
  }

  Future<List<PostModal>> getAllPosts(String cid) async {
    CollectionReference allPostRef = Firestore.instance.collection('allPosts');
    QuerySnapshot snapshot =
        await allPostRef.orderBy('timestamp', descending: true).getDocuments();

    List<PostModal> list = [];

    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      if (documentSnapshot.data['ownerID'] != cid) {
        PostModal post =
            await PostModal.getInstance(documentSnapshot.data, cid);
        list.add(post);
      }
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
    if (documentSnapshot.exists)
      return documentSnapshot.data['liked'];
    else
      return false;
  }

  manageLikes(PostModal post, String cid) async {
    try {
      DocumentReference documentReference = postRef
          .document(post.ownerID)
          .collection('postData')
          .document(post.postID)
          .collection('metaData')
          .document(cid);
      await documentReference
          .setData({'liked': post.isLiked, 'timestamp': DateTime.now()});
      //DocumentSnapshot documentSnapshot = await documentReference.get();
//      if (documentSnapshot.exists) {
//        await documentReference.delete();
//      } else {
//        documentReference.setData({});
//      }
    } catch (e) {
      throw e;
//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text('Something went wrong'),
//      ));
    }
  }

  Future<void> createPostDocument(String cid, String postId, Map doc) async {
    try {
      await postRef
          .document(cid)
          .collection('postData')
          .document(postId)
          .setData({
        'ownerID': cid,
        'postID': postId,
        'caption': doc['caption'],
        'thumbnailURL': doc['thumbnailURL'],
        'videoURL': doc['videoURL'],
        'timestamp': DateTime.now(),
        'tags': doc['tags']
      });
    } catch (e) {
      throw e;
    }
  }

//  Future<List<PostModal>> profilePopularPosts(String id) async {
//    QuerySnapshot snapshot = await postRef
//        .document(id)
//        .collection('postData')
//        .limit(5)
//        .getDocuments();
//
//    List<PostModal> list = [];
//
//    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
//      PostModal post = await PostModal.getInstance(documentSnapshot.data, id);
//      list.add(post);
//    }
//    return list;
//  }

  deleteProfileVideo(String uid, String docid) async {
    await postRef.document(uid).collection('postData').document(docid).delete();
  }

  Future<List<PostModal>> profileAllPosts(String uid) async {
    QuerySnapshot snapshot = await postRef
        .document(uid)
        .collection('postData')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<PostModal> list = [];

    for (DocumentSnapshot documentSnapshot in snapshot.documents) {
      PostModal post = await PostModal.getInstance(documentSnapshot.data, uid);
      list.add(post);
    }

    return list;
  }
}
