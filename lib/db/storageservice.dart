import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String> uploadFile(String filename, File file) async {
    try {
      final uploadTask = storageRef.child(filename).putFile(file);
      final storageSnap = await uploadTask.onComplete;
      String downloadUrl = await storageSnap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }
}
