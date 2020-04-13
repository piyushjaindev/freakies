const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
           .document("/follower/{userId}/userFollowers/{followerId}")
           .onCreate(async (snapshot, context) => {
               const userId = context.params.userId;
               const followerId = context.params.followerId;

                const postsRef = db.collection('posts').doc(userId).collection('postData');

                        const querySnapshot = await postsRef.get();

                        querySnapshot.forEach(doc => {

                            const postId = doc.id;
                            db.collection('timeline').doc(followerId).collection('posts').doc(postId).set({
                                                                                                     postID: postId,
                                                                                                     ownerID: userId,
                                                                                                     timestamp: doc.data().timestamp
                                                                                                 });

                        });

               const notificationRef = db.collection('notifications')
                   .doc(userId)
                   .collection('feeds');

               notificationRef.doc('follow_' + followerId).set({
                   type: 'follow',
                   userId: followerId,
                   timestamp: snapshot.data().timestamp,
               });
           });

exports.onDeleteFollower = functions.firestore
            .document("/follower/{userId}/userFollowers/{followerId}")
            .onDelete(async (snapshot, context) => {
                   const userId = context.params.userId;
                   const followerId = context.params.followerId;

                   const postsRef = db.collection('posts').doc(userId).collection('postData');

                                           const querySnapshot = await postsRef.get();

                                           querySnapshot.forEach(doc => {

                                               const postId = doc.id;
                                               db.collection('timeline').doc(followerId).collection('posts').doc(postId).delete();

                                           });

                   const notificationRef = db.collection('notifications')
                       .doc(userId)
                       .collection('feeds');

                   notificationRef.doc('follow_' + followerId).delete();
            });

exports.onCreateComment = functions.firestore
    .document("/comments/{postId}/commentsData/{commentId}")
    .onCreate(async (snapshot, context) => {
        const postId = context.params.postId;
        const commentId = context.params.commentId;
        if(snapshot.data().commenterID !== snapshot.data().ownerID){

        const notificationRef = db.collection('notifications')
            .doc(snapshot.data().ownerID)
            .collection('feeds');

        notificationRef.doc('comment_' + commentId).set({
            type: 'comment',
            postId: postId,
            ownerId: snapshot.data().ownerID,
            comment: snapshot.data().comment,
            userId: snapshot.data().commenterID,
            timestamp: snapshot.data().timestamp,
        });
        }
    });

exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/postData/{postId}")
    .onCreate(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        db.collection('allPosts').doc(postId).set({
            postID: postId,
            ownerID: userId,
            timestamp: snapshot.data().timestamp
        });

        const followersRef = db.collection('follower').doc(userId).collection('userFollowers');

        const querySnapshot = await followersRef.get();

        querySnapshot.forEach(doc => {

            const followerId = doc.id;
            db.collection('timeline').doc(followerId).collection('posts').doc(postId).set({
                                                                                     postID: postId,
                                                                                     ownerID: userId,
                                                                                     timestamp: snapshot.data().timestamp
                                                                                 });
            db.collection('notifications').doc(followerId).collection('feeds').doc('newpost_' + postId).set({
                                                                                          type: 'newpost',
                                                                                          userId: userId,
                                                                                          postId: postId,
                                                                                          ownerId: userId,
                                                                                          timestamp: Date(),
                                                                                      });

        });

    });

exports.onDeletePost = functions.firestore
    .document("/posts/{userId}/postData/{postId}")
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        db.collection('allPosts').doc(postId).delete();

                const followersRef = db.collection('follower').doc(userId).collection('userFollowers');

                const querySnapshot = await followersRef.get();

                querySnapshot.forEach(doc => {

                    const followerId = doc.id;
                    db.collection('timeline').doc(followerId).collection('posts').doc(postId).delete();
                        db.collection('notifications').doc(followerId).collection('feeds').doc('newpost_' + postId).delete();

                });
    });

exports.onLike = functions.firestore
    .document("/posts/{userId}/postData/{postId}/metaData/{watcherId}")
    .onWrite(async (change, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;
        const watcherId = context.params.watcherId;

        if(userId !== watcherId){

        const notificationRef = db.collection('notifications')
            .doc(userId)
            .collection('feeds');

        if(change.after.data().liked){
            notificationRef.doc('like_' + postId + '_' + watcherId).set({
                type: 'like',
                userId: watcherId,
                postId: postId,
                ownerId: userId,
                timestamp: change.after.data().timestamp,
            });
        } else {
                notificationRef.doc('like_' + postId + '_' + watcherId).delete();

        }
    }

    });

