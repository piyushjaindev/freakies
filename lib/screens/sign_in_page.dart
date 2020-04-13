import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/authservice.dart';
import 'package:freakies/modals/functions.dart' show checkUser;
import 'package:freakies/screens/edit_profile.dart';
import 'package:freakies/screens/home.dart';
import 'package:freakies/screens/reset_password.dart';

//enum PageType { signIn, signUp, convertGuest, loginWithoutConvert }

class SignInPage extends StatefulWidget {
  final PageType type;

  SignInPage({
    this.type = PageType.signUp,
  });

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _email;
  String _password;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  AuthService _authService = AuthService();
  Widget actionWidget;

  @override
  void initState() {
    if (widget.type == PageType.convertGuest ||
        widget.type == PageType.loginWithoutConvert) {
      actionWidget = IconButton(
        icon: Icon(Icons.close),
        iconSize: 35.0,
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      actionWidget = Text('');
    }
    checkCurrentUser();
    super.initState();
  }

  checkCurrentUser() async {
    try {
      if (widget.type == PageType.signIn || widget.type == PageType.signUp) {
        final _user = await _auth.currentUser();
        if (_user != null) {
          if (_user.isAnonymous) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Home()),
                (Route<dynamic> route) => false);
          } else {
            checkIfAlreadyRegisterd(firebaseUser: _user);
          }
        }
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong'),
      ));
    }
  }

  checkIfAlreadyRegisterd(
      {FirebaseUser firebaseUser, String name = '', String dpURL = ''}) async {
    try {
      bool isRegistered = await checkUser(firebaseUser.uid);
      if (isRegistered)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false);
      else
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EditProfile()));
    } catch (e) {
      throw e;
    }
  }

  loginUserMethod() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        _authService.login(_email, _password);
      }
//      try {
//        final user = await _auth.signInWithEmailAndPassword(
//            email: _email, password: _password);
//        if (user != null) {
//          FirebaseUser firebaseUser = await _auth.currentUser();
//          checkIfAlreadyRegisterd(firebaseUser: firebaseUser);
//        }
      catch (e) {
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
          case 'ERROR_WRONG_PASSWORD':
          case 'ERROR_USER_NOT_FOUND':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Invalid email or password'),
            ));
            break;
          case 'ERROR_USER_DISABLED':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('User disabled'),
            ));
            break;
          default:
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Something went wrong'),
            ));
            break;
        }
      }
    }
  }

  registerUserMethod() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        _authService.register(widget.type, _email, _password);
//        if (widget.type == PageType.convertGuest) {
//          final AuthCredential credential = EmailAuthProvider.getCredential(
//              email: _email, password: _password);
//          guestConvertMethod(credential);
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => EditProfile()));
//        } else {
//          final user = await _auth.createUserWithEmailAndPassword(
//              email: _email, password: _password);
//          if (user != null) {
//            FirebaseUser firebaseUser = await _auth.currentUser();
//            checkIfAlreadyRegisterd(firebaseUser: firebaseUser);
//          }
//        }
      } catch (e) {
        switch (e.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Email is already registered'),
            ));
            break;
          case 'ERROR_PROVIDER_ALREADY_LINKED':
          case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('This account is already connected'),
            ));
            break;
          case 'ERROR_USER_DISABLED':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('User disabled'),
            ));
            break;
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Email already registered'),
            ));
            break;
          default:
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Something went wrong'),
            ));
            break;
        }
      }
    }
  }

  void anonymousSignIn() async {
    try {
      final user = await _auth.signInAnonymously();
      if (user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong'),
      ));
    }
  }

  signInWithGoogle() async {
    try {
      _authService.googleSignIn(widget.type);
//      final googleSignIn = GoogleSignIn();
//      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: gSA.accessToken,
//        idToken: gSA.idToken,
//      );
//      if (widget.type == PageType.convertGuest) {
//        guestConvertMethod(credential);
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (context) => EditProfile(
//                      name: googleSignInAccount.displayName,
//                      dpURL: googleSignInAccount.photoUrl,
//                    )));
//      } else {
//        final AuthResult authResult =
//            await _auth.signInWithCredential(credential);
//        FirebaseUser firebaseUser = authResult.user;
//        checkIfAlreadyRegisterd(
//            firebaseUser: firebaseUser,
//            name: googleSignInAccount.displayName,
//            dpURL: googleSignInAccount.photoUrl);
//      }
    } catch (e) {
      switch (e.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Email is already registered'),
          ));
          break;
        case 'ERROR_PROVIDER_ALREADY_LINKED':
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('This account is already connected'),
          ));
          break;
        case 'ERROR_USER_DISABLED':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('User disabled'),
          ));
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Email already registered'),
          ));
          break;
        default:
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Something went wrong'),
          ));
          break;
      }
    }
  }

  signInWithFacebook() async {
    try {
      _authService.facebookSignIn(widget.type);
//      final fbLogin = FacebookLogin();
//      final result = await fbLogin.logIn(['email']);
//      switch (result.status) {
//        case FacebookLoginStatus.loggedIn:
//          final token = result.accessToken.token;
//          final graphResponse = await http.get(
//              'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token');
//          final profile = JSON.jsonDecode(graphResponse.body);
//          final AuthCredential facebookAuthCred =
//              FacebookAuthProvider.getCredential(accessToken: token);
//          if (widget.type == PageType.convertGuest) {
//            guestConvertMethod(facebookAuthCred);
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => EditProfile(
//                          name: profile['name'],
//                          dpURL: profile['pictures']['data']['url'],
//                        )));
//          } else {
//            final AuthResult authResult =
//                await _auth.signInWithCredential(facebookAuthCred);
//            FirebaseUser firebaseUser = authResult.user;
//            checkIfAlreadyRegisterd(
//                firebaseUser: firebaseUser,
//                name: profile['name'],
//                dpURL: profile['pictures']['data']['url']);
//          }
//          break;
//        case FacebookLoginStatus.cancelledByUser:
//          _scaffoldKey.currentState.showSnackBar(SnackBar(
//            content: Text('Login cancelled'),
//          ));
//          break;
//        case FacebookLoginStatus.error:
//          print(result.errorMessage);
//          _scaffoldKey.currentState.showSnackBar(SnackBar(
//            content: Text('Something went wrong'),
//          ));
//          break;
//      }
    } catch (e) {
      switch (e.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Email is already registered'),
          ));
          break;
        case 'ERROR_PROVIDER_ALREADY_LINKED':
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('This account is already connected'),
          ));
          break;
        case 'ERROR_USER_DISABLED':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('User disabled'),
          ));
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Email already registered'),
          ));
          break;
        default:
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Something went wrong'),
          ));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[actionWidget],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome',
                    style:
                        TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'enter your details',
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  buildForm(widget.type),
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(flex: 1),
                      Text('Continue With:'),
                      Spacer(flex: 1),
                      GestureDetector(
                        onTap: signInWithGoogle,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            //shape: BoxShape.circle,
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/google_logo.png'),
                                fit: BoxFit.fill),
                          ),
                          width: 40.0,
                          height: 40.0,
                        ),
                      ),
                      Spacer(flex: 1),
                      GestureDetector(
                        onTap: signInWithFacebook,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            //shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('assets/images/fb_logo.png'),
                                fit: BoxFit.fill),
                          ),
                          width: 40.0,
                          height: 40.0,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  widget.type == PageType.signIn ||
                          widget.type == PageType.loginWithoutConvert
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              if (widget.type == PageType.signIn)
                                return SignInPage(
                                  type: PageType.signUp,
                                );
                              return SignInPage(
                                type: PageType.convertGuest,
                              );
                            }));
                          },
                          child: RichText(
                            text: TextSpan(
                                text: 'Don\'t have an account? ',
                                style: Theme.of(context).textTheme.subtitle,
                                children: [
                                  TextSpan(
                                      text: 'Sign Up Now!',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 18.0)
                                      //style: Text
                                      )
                                ]),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              if (widget.type == PageType.signUp)
                                return SignInPage(
                                  type: PageType.signIn,
                                );
                              return SignInPage(
                                type: PageType.loginWithoutConvert,
                              );
                            }));
                          },
                          child: RichText(
                            text: TextSpan(
                                text: 'Already have an account? ',
                                style: Theme.of(context).textTheme.subtitle,
                                children: [
                                  TextSpan(
                                      text: 'Login here!',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 18.0)
                                      //style: Text
                                      )
                                ]),
                          ),
                        ),
                  SizedBox(
                    height: 15.0,
                  ),
                  widget.type == PageType.signUp
                      ? OutlineButton(
                          highlightElevation: 2.0,
                          textColor: Theme.of(context).accentColor,
                          highlightedBorderColor: Theme.of(context).accentColor,
                          onPressed: anonymousSignIn,
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                              decorationColor: Theme.of(context).accentColor,
                            ),
                          ),
                        )
                      : widget.type == PageType.signIn ||
                              widget.type == PageType.loginWithoutConvert
                          ? FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ResetPassword()));
                              },
                              textColor: Theme.of(context).accentColor,
                              child: Text('Forgot password?'),
                            )
                          : Text('')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Form buildForm(PageType type) {
    bool isSignIn =
        type == PageType.signIn || type == PageType.loginWithoutConvert;

    return Form(
        key: _formKey,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  focusColor: Colors.green,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  )),
              onSaved: (val) {
                _email = val.trim();
              },
              validator: (val) {
                if (!val.contains('@') ||
                    !val.contains('.') ||
                    val.contains(' ')) return 'Invalid email address';
                return null;
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: Theme.of(context).primaryColor,
                  )),
              onSaved: (val) {
                _password = val;
              },
              onChanged: (val) {
                _password = val;
              },
              validator: (val) {
                if (val.length < 6)
                  return 'Password must be of atleast 6 characters';
                return null;
              },
              obscureText: true,
            ),
            isSignIn
                ? SizedBox(
                    height: 0,
                  )
                : Column(children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Retype your password',
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            color: Theme.of(context).primaryColor,
                          )),
                      validator: (val) {
                        if (val != _password) return 'Password doesn\'t match';
                        return null;
                      },
                      obscureText: true,
                    ),
                  ]),
            SizedBox(
              height: 15.0,
            ),
            isSignIn
                ? FlatButton(
                    child: Text('Login'),
                    color: Theme.of(context).primaryColor,
                    onPressed: loginUserMethod,
                  )
                : FlatButton(
                    child: Text(
                      'Register',
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
//                      shape: StadiumBorder(
//                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2.0, style: BorderStyle.solid,)
//                      ),
                    color: Theme.of(context).primaryColor,
                    onPressed: registerUserMethod,
                  )
          ],
        ));
  }
}
