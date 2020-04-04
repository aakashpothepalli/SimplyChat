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
    socket.getChats(widget.uid);//load the chats for the specific uid
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
        builder: (context,socket ,widget) {
          if(socket.chatsList.length==0){
            return Center(child: CircularProgressIndicator());
          }
          else{
            return ListView.builder(
              itemCount: socket.chatsList.length,
              itemBuilder: (BuildContext context,int index){
                
                socket.connect2room(socket.chatsList[index]['roomId'], this.myUid); //connects to all the chat rooms 
                String roomId =socket.chatsList[index]['roomId'];
                return ChatTile(
                  profileName: socket.chatsList[index]['profileName'].toString(),
                  recentMessage: socket.latestMessages[roomId].toString(),
                  profileUid: socket.chatsList[index]['profileUid'].toString(),
                  myUid: this.myUid ,
                  roomId:roomId.toString() ,
                  messageCount: socket.messages[roomId].length,);
              }
            );
          }
        }
      )
    );
  }
}