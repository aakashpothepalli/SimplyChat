import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/myWebsocket.dart';

class ChatPage extends StatefulWidget {
  String receiverUid;//to whom the person is chatting
  String myUid;//the person himself
  ChatPage({this.receiverUid,this.myUid});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    var socket = Provider.of<MyWebsocket>(context,listen:true);

    return Scaffold(
      appBar:AppBar(title: Text("my"),) ,
      body: Center(
        child:RaisedButton(
          onPressed: (){
           socket.send('{"channel":"dm","sender":"${widget.myUid}","receiver":"${widget.receiverUid}","message":"hello"}');
          },
          child: Text("click to send hi"),
        ),
      ),
    );
  }
}