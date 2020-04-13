import 'dart:convert' as JSON;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:freakies/db/userservice.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

enum PageType { signIn, signUp, convertGuest, loginWithoutConvert }

class AuthService {
  final _auth = FirebaseAuth.instance;

  checkCurrentUser(PageType type) async {
    try {
      if (type == PageType.signIn || type == PageType.signUp) {
        final _user = await _auth.currentUser();
        if (_user != null) {
          if (_user.isAnonymous) {
//            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//                builder: (context) => Home(user: _user,)),
//                    (Route<dynamic> route) => false);
          } else {
            checkIfAlreadyRegisterd(firebaseUser: _user);
          }
        }
      }
    } catch (e) {
      // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
    }
  }

  checkIfAlreadyRegisterd(
      {FirebaseUser firebaseUser, String name = '', String dpURL = ''}) async {
    try {
      bool isRegistered = await UserService().checkUser(firebaseUser.uid);
      if (isRegistered) {
      }
//        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//            builder: (context) => Home(user: firebaseUser,)),
//                (Route<dynamic> route) => false);
      else {}
//        Navigator.push(context, MaterialPageRoute(
//            builder: (context) => EditProfile(name: name, dpURL: dpURL,)));
    } catch (e) {
      throw e;
    }
  }

  void login(String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
//      if (user != null) {
//        return true;
//        FirebaseUser firebaseUser = await _auth.currentUser();
//        checkIfAlreadyRegisterd(firebaseUser: firebaseUser);
//      }
    } catch (e) {
      throw e;
//      switch (e.code) {
//        case 'ERROR_INVALID_EMAIL':
//        case 'ERROR_WRONG_PASSWORD':
//        case 'ERROR_USER_NOT_FOUND':
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Invalid email or password'),));
//          break;
//        case 'ERROR_USER_DISABLED':
//          //  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('User disabled'),));
//          break;
//        default:
//          //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
//          break;
//      }
    }
  }

  register(PageType type, String email, String password) async {
    try {
      if (type == PageType.convertGuest) {
        final AuthCredential credential =
            EmailAuthProvider.getCredential(email: email, password: password);
        guestConvertMethod(credential);
//          Navigator.push(context, MaterialPageRoute(
////              builder: (context) => EditProfile()));
      } else {
        final user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
//        if (user != null) {
//          FirebaseUser firebaseUser = await _auth.currentUser();
//          checkIfAlreadyRegisterd(firebaseUser: firebaseUser);
//        }
      }
    } catch (e) {
      throw e;
//      switch (e.code) {
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email is already registered'),));
//          break;
//        case 'ERROR_PROVIDER_ALREADY_LINKED':
//        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('This account is already connected'),));
//          break;
//        case 'ERROR_USER_DISABLED':
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('User disabled'),));
//          break;
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email already registered'),));
//          break;
//        default:
//          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
//          break;
//      }
    }
  }

  guestConvertMethod(AuthCredential credential) async {
    try {
      FirebaseUser firebaseUser = await _auth.currentUser();
      await firebaseUser.linkWithCredential(credential);
      await firebaseUser.reload();
    } catch (e) {
      throw e;
    }
  }

  void anonymousSignIn() async {
    try {
      final user = await _auth.signInAnonymously();
      if (user != null) {
        FirebaseUser firebaseUser = await _auth.currentUser();
//        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//            builder: (context) => Home(user: firebaseUser,)), (
//            Route<dynamic> route) => false);
      }
    } catch (e) {
      //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
    }
  }

  googleSignIn(PageType type) async {
    try {
      final googleSignIn = GoogleSignIn();
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: gSA.accessToken,
        idToken: gSA.idToken,
      );
      if (type == PageType.convertGuest) {
        guestConvertMethod(credential);
        //  Navigator.push(context, MaterialPageRoute(
        //      builder: (context) => EditProfile(name: googleSignInAccount.displayName, dpURL: googleSignInAccount.photoUrl,)));

      } else {
        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        FirebaseUser firebaseUser = authResult.user;
        checkIfAlreadyRegisterd(
            firebaseUser: firebaseUser,
            name: googleSignInAccount.displayName,
            dpURL: googleSignInAccount.photoUrl);
      }
    } catch (e) {
      throw e;
//      switch (e.code) {
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          //     _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email is already registered'),));
//          break;
//        case 'ERROR_PROVIDER_ALREADY_LINKED':
//        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
//          //    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('This account is already connected'),));
//          break;
//        case 'ERROR_USER_DISABLED':
//          //    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('User disabled'),));
//          break;
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          //    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email already registered'),));
//          break;
//        default:
//          //     _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
//          break;
//      }
    }
  }

  facebookSignIn(PageType type) async {
    try {
      final fbLogin = FacebookLogin();
      final result = await fbLogin.logIn(['email']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final token = result.accessToken.token;
          final graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');
          final profile = JSON.jsonDecode(graphResponse.body);
          final AuthCredential facebookAuthCred =
              FacebookAuthProvider.getCredential(accessToken: token);
          if (type == PageType.convertGuest) {
            guestConvertMethod(facebookAuthCred);
            //  Navigator.push(context, MaterialPageRoute(
            //      builder: (context) => EditProfile(name: profile['name'], dpURL: profile['pictures']['data']['url'],)));
          } else {
            final AuthResult authResult =
                await _auth.signInWithCredential(facebookAuthCred);
            FirebaseUser firebaseUser = authResult.user;
            checkIfAlreadyRegisterd(
                firebaseUser: firebaseUser,
                name: profile['name'],
                dpURL: profile['pictures']['data']['url']);
          }
          break;
        case FacebookLoginStatus.cancelledByUser:
          throw Exception('Facebook login cancelled by user');
          break;
        case FacebookLoginStatus.error:
          throw Exception('Something went wrong');
          break;
      }
    } catch (e) {
      throw e;
//      switch (e.code) {
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email is already registered'),));
//          break;
//        case 'ERROR_PROVIDER_ALREADY_LINKED':
//        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
//          //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('This account is already connected'),));
//          break;
//        case 'ERROR_USER_DISABLED':
//          //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('User disabled'),));
//          break;
//        case 'ERROR_EMAIL_ALREADY_IN_USE':
//          //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Email already registered'),));
//          break;
//        default:
//          //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Something went wrong'),));
//          break;
//      }
    }
  }
}
