import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_modal.dart';

Future<User> createUserObject(String id) async {
  try {
    final userRef = Firestore.instance.collection('users');
    DocumentSnapshot documentSnapshot = await userRef.document(id)
        .get();
    final doc = documentSnapshot.data;
    return User.create(doc);
  } catch(e){
    print(e);
    throw e;
  }
}

 Future<bool> validateUsername(String username) async {
  try {
    final userRef = Firestore.instance.collection('users');
    print(username);
    final querySnapshot = await userRef.where('username', isEqualTo: username).limit(1).getDocuments();
    final doc = querySnapshot.documents;
    //print(doc.first.documentID);
    if(doc.length < 1)
      return true;
    else
      return false;
  } catch(e) {
    print(e);
    throw e;
  }
}

// returns true if user details are saved in database
Future<bool> checkUser(String docID) async {
  try {
    final userRef = Firestore.instance.collection('users');
    final doc = await userRef.document(docID).get();
    if(doc.exists)
      return true;
    else
      return false;
  } catch(e) {
    print(e);
    throw e;
  }
}

// returns true if email is not registered
Future<bool> checkEmail(String email) async {
  try {
    final userRef = Firestore.instance.collection('users');
    final querySnapshot = await userRef.where({'email': email}).limit(1).getDocuments();
    final doc = querySnapshot.documents;
    if(doc.length < 1)
      return true;
    else {
      return false;
    }
  } catch(e) {
    print(e);
    throw e;
  }
}