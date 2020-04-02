import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/ChatPage/chatPage.dart';
import 'package:simplychat/home/chatTile.dart';
import 'package:simplychat/myWebsocket.dart';

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
  List<String> chats = ["aakash","arun","anas"];
  String myUid;
  @override
  void initState() {
    var socket = Provider.of<MyWebsocket>(context,listen: false);
    socket.send('{"channel":"getChats","uid":"${widget.uid}"}');
    this.myUid  = widget.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('SimplyChat'),
        actions: <Widget>[
          // Icon(Icons.message),
          IconButton(
            icon: Icon(Icons.search,),
            onPressed: (){
              Navigator.push(context, new MaterialPageRoute(builder: (context)=>ChatPage()));
            },
          )
        ],
      ),
      body:Consumer<MyWebsocket>(
        builder: (context,ws ,widget) {
          if(ws.chatsList.length==0){
            return Center(child: CircularProgressIndicator());
          }
          else{
            return ListView.builder(
              itemCount: ws.chatsList.length,
              itemBuilder: (BuildContext context,int index){
                return ChatTile(
                  profileName: ws.chatsList[index]['profileName'].toString(),
                  recentMessage: ws.chatsList[index]['recentMessage'].toString(),
                  profileUid: ws.chatsList[index]['profileUid'].toString(),
                  myUid: this.myUid ,);
              }
            );
          }
        }
      )
    );
  }
}