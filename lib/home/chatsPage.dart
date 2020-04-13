import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/ChatPage/chatPage.dart';
import 'package:simplychat/Login%20%E2%81%84%20Signup/loginPage.dart';
import 'package:simplychat/home/chatTile.dart';
import 'package:simplychat/myWebsocket.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatsPage extends StatefulWidget {
  String uid;
  ChatsPage({@required this.uid});
  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState  extends State<ChatsPage>{
  var socket;
  String data="";
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
    final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn(scopes: ['email']);

  String myUid;
  //TODO : implement local storage here
  
  @override
  void initState() {
    var socket = Provider.of<MyWebsocket>(context,listen: false);
    socket.getChats(widget.uid);//load the chats for the specific uid
    this.myUid  = widget.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<MyWebsocket>(
        builder: (context,socket ,widget) {
          if(socket.chatsList.length==0){
           return SliverList(
            ///Use SliverChildListDelegate and provide a list
            ///of widgets if the count is limited
            ///
            ///Lazy building of list
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                /// To convert this infinite list to a list with "n" no of items,
                /// uncomment the following line:
                /// if (index > n) return null;
                if(index==1)return null;
                else
                return Container(child: LinearProgressIndicator(),);
              },
              /// Set childCount to limit no.of items
              /// childCount: 100,
            )
           );
          }
          else{
            return SliverList(
              // itemCount: socket.chatsList.length,

              delegate: SliverChildBuilderDelegate( 

                (BuildContext context,int index){
                  if(index>=socket.chatsList.length+31)return null;
                  else if(index>=socket.chatsList.length && index<socket.chatsList.length+31)return Text("");

                  print(socket.unReadmessagesCount[socket.chatsList[index]['roomId']]);

                  socket.connect2room(socket.chatsList[index]['roomId'], this.myUid); //connects to all the chat rooms 
                  String roomId =socket.chatsList[index]['roomId'];
                  print(index);
                  
                  return ChatTile(
                    profileName: socket.chatsList[index]['profileName'].toString(),
                    profilePic: socket.chatsList[index]['profilePic'].toString(),
                    recentMessage: socket.messages[roomId][socket.messages[roomId].length-1].text,
                    profileUid: socket.chatsList[index]['profileUid'].toString(),
                    myUid: this.myUid ,
                    roomId:roomId.toString() ,
                    messageCount: socket.unReadmessagesCount[roomId],);
                }
              )
            );
          }
        }
      );
  }
}