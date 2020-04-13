import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simplychat/Login%20%E2%81%84%20Signup/loginPage.dart';
import 'package:simplychat/home/chatsPage.dart';
import 'package:simplychat/myWebsocket.dart';
import 'package:provider/provider.dart';
void main() => runApp(
  ChangeNotifierProvider(
      create: (context) => MyWebsocket(),
      child: MyApp(),
    ),);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplyChat',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn(scopes: ['email']);
  FirebaseUser user;
  @override
  void initState() {
    getUser().then((user1) {
      if (user1 == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } 
      else{
        print("logged in");
        setState(() {
          this.user =user1;
        });
      }
    });
    // auth.signOut();
    // googleSignIn.objectsignOut();
    super.initState();
  }

  Future<FirebaseUser> getUser() async {
    return auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    if(this.user==null){
      return Scaffold(
        body: Text('SimplyChat :)'),
      );
    }
    else return Scaffold(

      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
             title:Text('SimplyChat') ,
            pinned: true,
            // flexibleSpace: const FlexibleSpaceBar(
            //   title: Text('SimplyChat'),
              
            // ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Signout',
                onPressed: () {
                  googleSignIn.signOut();
                  auth.signOut();
                  Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>LoginPage()));
                },
              ),
             
            ]
          ),
          
          ChatsPage(uid: this.user.uid,),
        ],
      ),
    );
  }
}
