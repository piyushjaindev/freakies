import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/userservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/size_config.dart';
import 'package:freakies/screens/home.dart';
import 'package:http/http.dart' show get;
import 'package:image/image.dart' as IM;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum ActionType { edit, complete }

class EditProfile extends StatefulWidget {
  final ActionType type;

  /*final String type;
  final GoogleSignInAccount googleUser;
  final String facebookToken;*/

  EditProfile({
    this.type = ActionType.complete,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String _fullName;
  String _username;
  String _bio;
  String _dpURL;
  File _dpFile;
  bool dpChanged = false;
  bool isUsernameAvailable = true;
  final _formKey = GlobalKey<FormState>();
  final userRef = Firestore.instance.collection('users');
  final storageRef = FirebaseStorage.instance.ref();
  final _auth = FirebaseAuth.instance;
  String randomID = Uuid().v4();
  FirebaseUser user;
  CurrentUser currentUser;
  TextEditingController nameController;
  TextEditingController usernameController;
  TextEditingController bioController;

  @override
  void initState() {
    user = Provider.of<FirebaseUser>(context);
    currentUser = Provider.of<CurrentUser>(context);
    nameController = TextEditingController();
    usernameController = TextEditingController();
    bioController = TextEditingController();
    getUserDetails();
    super.initState();
    //checkType();
  }

  Future<void> getUserDetails() async {
    try {
      if (widget.type == ActionType.complete) {
        if (user.displayName.isNotEmpty) {
          _fullName = user.displayName;
          nameController.text = _fullName;
        }
        if (user.photoUrl.isNotEmpty) {
          getDpFile(user.photoUrl);
        }
      } else {
        final documentSnapshot = await userRef.document(user.uid).get();
        if (documentSnapshot.exists) {
          final doc = documentSnapshot.data;
          _fullName = doc['fullName'];
          _username = doc['username'];
          _bio = doc['bio'];
          _dpURL = doc['dpURL'];
          getDpFile(doc['dpURL']);
          nameController.text = _fullName;
          usernameController.text = _username;
          bioController.text = _bio;
        }
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching user details'),
      ));
    }
  }

  Future<void> getDpFile(dpURL) async {
    var response = await get(dpURL);
    _dpFile = await compressImage(bytes: response.bodyBytes, quality: 100);
    setState(() {});
  }

  Future<void> updateUserMethod() async {
    try {
      isUsernameAvailable = widget.type == ActionType.edit
          ? true
          : await UserService()
              .validateUsername(usernameController.text.toLowerCase());
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        //FirebaseUser firebaseUser = await _auth.currentUser();
        if (widget.type == ActionType.edit) {
          _dpFile = dpChanged
              ? await compressImage(
                  bytes: _dpFile.readAsBytesSync(), quality: 85)
              : null;
          _dpURL = dpChanged ? await uploadImage(user.uid) : _dpURL;
          Map<String, dynamic> userMap = {
            'fullName': _fullName,
            'name': _fullName.toLowerCase(),
            'bio': _bio,
            'dpURL': _dpURL
          };
          await currentUser.updateUserDocument(userMap);
          //Navigator.pop(context, currentUser: widget.currentUser);
        } else {
          if (_dpFile != null)
            _dpFile = await compressImage(
                bytes: _dpFile.readAsBytesSync(), quality: 85);
          Map<String, dynamic> userMap = {
            'fullName': _fullName,
            'name': _fullName.toLowerCase(),
            'username': _username,
            'bio': _bio,
            'id': user.uid,
            'email': user.email,
            'timestamp': DateTime.now(),
            'dpURL': _dpFile != null
                ? await uploadImage(user.uid)
                : 'https://firebasestorage.googleapis.com/v0/b/freakies-f9a09.appspot.com/o/profile.jpg?alt=media&token=1857b905-be18-41d9-ac2b-4368d741bddc',
          };
          await currentUser.createUserDocument(userMap);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error updating user details'),
      ));
    }
  }

  Future<File> compressImage({Uint8List bytes, int quality}) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    IM.Image imageFile = IM.decodeImage(bytes);
    final File tempFile = File('$path/img_$randomID.jpg')
      ..writeAsBytesSync(IM.encodeJpg(imageFile, quality: quality));
    return tempFile;
  }

  Future<String> uploadImage(String id) async {
    try {
      final uploadTask = storageRef.child('dp_$id.jpg').putFile(_dpFile);
      final storageSnap = await uploadTask.onComplete;
      String downloadUrl = await storageSnap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }

  showImagePicker(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return Theme(
            data: ThemeData(
                iconTheme: IconThemeData(color: Color(0xFF31353A), size: 25.0)),
            child: SimpleDialog(
              title: Text('Select an option'),
              children: <Widget>[
                SimpleDialogOption(
                  child: Row(children: [
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 3.0,
                    ),
                    Text('Camera')
                  ]),
                  onPressed: () {
                    imageFromCamera(context);
                  },
                ),
                SimpleDialogOption(
                  child: Row(children: [
                    Icon(Icons.image),
                    SizedBox(
                      width: 3.0,
                    ),
                    Text('Gallery')
                  ]),
                  onPressed: () {
                    imageFromGallery(context);
                  },
                ),
                SimpleDialogOption(
                  child: Row(children: [
                    Icon(Icons.close),
                    SizedBox(
                      width: 3.0,
                    ),
                    Text('Cancel')
                  ]),
                  onPressed: () {
                    dpChanged = false;
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }

  imageFromCamera(context) async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 512, maxWidth: 512);
    if (file != null) {
      setState(() {
        _dpFile = file;
      });
    } else {
      dpChanged = false;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('No image selected'),
      ));
    }
  }

  imageFromGallery(context) async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file != null) {
      setState(() {
        _dpFile = file;
      });
    } else {
      dpChanged = false;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('No image selected'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        if (widget.type == ActionType.edit) return true;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('You have to complete your profile first'),
        ));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.type == ActionType.edit,
          title: widget.type == ActionType.complete
              ? Text('Complete profile')
              : Text('Edit profile'),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.mainWidth * 0.05,
                right: SizeConfig.mainWidth * 0.05,
                top: SizeConfig.mainHeight * 0.02,
                bottom: 0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      dpChanged = true;
                      showImagePicker(context);
                    },
                    child: CircleAvatar(
                      backgroundImage: _dpFile == null
                          ? AssetImage("assets/images/profile.jpg")
                          : FileImage(_dpFile),
                      radius: SizeConfig.mainWidth * 0.15,
                    ),
                  ),
                  Text('Choose your profile picture'),
                  SizedBox(
                    height: 15.0,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            controller: nameController,
                            maxLength: 20,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              focusColor: Colors.green,
                              labelText: 'Name',
                              hintText: 'Your full name',
                              //icon: Icon(Icons.)
                            ),
                            onSaved: (val) {
                              _fullName = val.trim();
                            },
                            validator: (val) {
                              if (val.length < 3)
                                return 'Name is too short.';
                              else if (val.length > 20)
                                return 'Name is too large';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            controller: usernameController,
                            maxLength: 12,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Choose your username',
                              //icon: Icon(Icons.vpn_key)
                            ),
                            enabled: !(widget.type == ActionType.edit),
                            onSaved: (val) {
                              _username = val.trim().toLowerCase();
                            },
                            validator: (val) {
                              if (val.isEmpty || val == ' ')
                                return 'Invalid username';
                              else if (val.length < 3)
                                return 'Username is too short.';
                              else if (val.length > 12)
                                return 'Username is too large';
                              else if (!isUsernameAvailable)
                                return 'Username is already taken';
                              else if (val.contains(' '))
                                return 'Invalid email address';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            controller: bioController,
                            textInputAction: TextInputAction.done,
                            //expands: true,
                            //minLines: 1,
                            maxLengthEnforced: true,
                            maxLines: 4,
                            maxLength: 50,
                            decoration: InputDecoration(
                              focusColor: Colors.green,
                              labelText: 'Bio',
                              hintText: 'Describe yourself',
                              //icon: Icon(Icons.)
                            ),
                            onSaved: (val) {
                              _bio = val.trim();
                            },
                            validator: (val) {
                              return;
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          RaisedButton(
                            child: Text("Submit"),
                            onPressed: updateUserMethod,
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
