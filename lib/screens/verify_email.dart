import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  FirebaseUser user;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

//  checkUser() async {
//    try {
//      user = await _auth.currentUser();
//      if (user.isEmailVerified) {
//        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//            builder: (context) => Home(user: user)),
//                (Route<dynamic> route) => false);
//      }
//    } catch(e){
//      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Something went wrong'),));
//      //Navigator.pop(context);
//    }
//  }

  @override
  void initState() {
    //  checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 35.0,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                'One more step!',
                style: Theme.of(context).textTheme.body2,
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                'Verify your email address to enjoy all benefits of this app.',
              ),
              Spacer(
                flex: 1,
              ),
              RaisedButton(
                child: Text(
                  'Send Verification Email',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
                onPressed: () async {
                  try {
                    await user.sendEmailVerification();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Verification email sent to ${user.email}'),
                    ));
                  } catch (e) {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Something went wrong'),
                    ));
                  }
                },
              ),
              Spacer(
                flex: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
