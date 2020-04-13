class CommentsModal {
  String comment;
  String username;
  String dpURL;
  String commentID;
  String ownerID;
  String postID;

  CommentsModal(
      {this.username,
      this.dpURL,
      this.comment,
      this.ownerID,
      this.commentID,
      this.postID});

  factory CommentsModal.create(doc) {
    return CommentsModal(
      comment: doc['comment'],
      username: doc['username'],
      dpURL: doc['dpURL'],
      commentID: doc['commentID'],
      postID: doc['postID'],
      ownerID: doc['ownerID'],
    );
  }
}
