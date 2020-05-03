import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatelessWidget {
  String _newPassword;
  String _oldPassword;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //Text('Changing your password is so easy'),
            SizedBox(
              height: 10.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Old Password',
                        hintText: 'Enter your old password',
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).primaryColor,
                        )),
                    onSaved: (val) {
                      _oldPassword = val;
                    },
                    validator: (val) {
                      if (val.length < 6)
                        return 'Password must be of atleast 6 characters';
                      return null;
                    },
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).primaryColor,
                        )),
                    onSaved: (val) {
                      _newPassword = val;
                    },
                    onChanged: (val) {
                      _newPassword = val;
                    },
                    validator: (val) {
                      if (val.length < 6)
                        return 'Password must be of atleast 6 characters';
                      return null;
                    },
                    obscureText: true,
                  ),
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
                      if (val != _newPassword) return 'Password doesn\'t match';
                      return null;
                    },
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    child: Text('Change Password'),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        try {
                          final _user = Provider.of<FirebaseUser>(context);
                          AuthCredential credential =
                              EmailAuthProvider.getCredential(
                                  email: _user.email, password: _oldPassword);
                          AuthResult authResult = await _user
                              .reauthenticateWithCredential(credential);

                          await authResult.user.updatePassword(_newPassword);
                        } catch (e) {
                          switch (e.code) {
                            case 'ERROR_USER_DISABLED':
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('User disabled'),
                              ));
                              break;
                            case 'ERROR_USER_NOT_FOUND':
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('No user found'),
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
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
