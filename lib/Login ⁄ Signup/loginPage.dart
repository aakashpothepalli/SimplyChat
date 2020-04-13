import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/main.dart';
import 'dart:async';

import '../myWebsocket.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    getUser().then((user) {
      if (user != null) {
        print('Already logged in as ' + user.displayName);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        print("Not logged in");
      }
    });

    super.initState();
  }

  Future<void> signIn() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      print('signed in as ' + user.displayName);
      var socket = Provider.of<MyWebsocket>(context,listen: false);
      socket.auth(user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
     
    } catch (err) {
      print(err);
    }
  }

  Future<FirebaseUser> getUser() async {
    return auth.currentUser();
  }

  void showSnackbar(String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child:FlatButton(
            child: Image.network("https://developers.google.com/identity/images/btn_google_signin_light_normal_web.png"),
            onPressed: signIn
        ),
      ),
    
    );
  }
}
