import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatelessWidget {

  String _newPassword;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Changing your password is so easy'),
              SizedBox(height: 10.0,),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter new password',
                          prefixIcon: Icon(Icons.vpn_key, color: Theme.of(context).primaryColor,)
                      ),
                      onSaved: (val){
                        _newPassword = val;
                      },
                      onChanged: (val) {
                        _newPassword = val;
                      },
                      validator: (val){
                        if(val.length < 6)
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
                          prefixIcon: Icon(Icons.vpn_key, color: Theme
                              .of(context)
                              .primaryColor,)
                      ),
                      validator: (val) {
                        if (val != _newPassword)
                          return 'Password doesn\'t match';
                        return null;
                      },
                      obscureText: true,
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      child: Text('Change Password'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          try {
                            final _auth = FirebaseAuth.instance;
                            final _user = await _auth.currentUser();
                            await _user.updatePassword(_newPassword);
                          } catch(e){
                            switch(e.code){
                              case 'ERROR_USER_DISABLED':
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('User disabled'),));
                                break;
                              case 'ERROR_USER_NOT_FOUND':
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('No user found'),));
                                break;
                              default:
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Something went wrong'),));
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
      ),
    );
  }
}
