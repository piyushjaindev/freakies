import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatelessWidget {

  String _email;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot password?'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Don\'t worry! We got you covered.'),
              SizedBox(height: 10,),
              Text('Follow the link sent to your email to reset your password...'),
              SizedBox(height: 10,),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(

                      decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email)
                      ),
                      onSaved: (val){
                        _email = val;
                      },
                      validator: (val){
                        if(!val.contains('@') || !val.contains('.') || val.contains(' '))
                          return 'Invalid email address';
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    RaisedButton(
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          _formKey.currentState.save();
                          try {
                            _auth.sendPasswordResetEmail(email: _email);
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Email sent'),));
                          } catch(e){
                            if(e.code == 'ERROR_USER_NOT_FOUND')
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('No user registered with this email'),));
                            else
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Something went wrong'),));
                          }
                        }
                      },
                      child: Text('Send Email', style: TextStyle(fontSize: 15),),
                    ),
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
