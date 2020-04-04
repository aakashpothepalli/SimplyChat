import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/myWebsocket.dart';
import 'dashChatEdit/dash_chat.dart';

class ChatPage extends StatefulWidget {
  final String receiverUid;
  final String roomId;
  final myUid;
  ChatPage({this.receiverUid, this.myUid, this.roomId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  List<ChatMessage> messages = [];
  var myUid;
  @override
  void initState() {
    this.myUid = widget.myUid;
    super.initState();
  }

  onSend(socket,chatMessage) {
    socket.sendMessage(widget.myUid,widget.roomId,chatMessage.text);
    this.messages.add(chatMessage);

  }
  onMessageReceived(messageMap){
      var messagesQueue = messageMap[widget.roomId];
      
        while(messagesQueue.length!=0){
          var userReq = jsonDecode(messagesQueue.first);
          messagesQueue.removeFirst();
          print("onMessage RE");
       
          print("this message belongs to "+widget.roomId);
          this.messages.add(  
            ChatMessage(
              text: userReq['message'],
              user:ChatUser(
                name: "Suraj Kumar",
                uid: userReq['sender'],
                ),
            ));
          }
        
      }
  
  @override
  Widget build(BuildContext context) {
    // this.socket = Provider.of<MyWebsocket>(context,listen: true);
    // setState(() {
    //   this.messages = this.socket.messages;
    // });
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage("https://avatars3.githubusercontent.com/u/37346450?s=460&v=4")),
              ),
              SizedBox(width: 10,),
              Text(
                "Suraj Kumar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
    
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<MyWebsocket>(
            builder: (context,socket ,widget) {
              onMessageReceived(socket.messages);

              return  DashChat(
                //showUserAvatar: true,
                
                messages: this.messages,
                inputMaxLines: 5,
                showAvatarForEveryMessage: false,
                onSend: (chatMessage) {
                  onSend(socket, chatMessage);
                },
                scrollToBottom: false,   
                scrollToBottomWidget: (){return Container();},
                timeFormat: DateFormat.Hm(),
                //leading: <Widget>[Container(width: 20,)],
                user: ChatUser(
                    name:"aakash",
                    uid: this.myUid,),

                inputToolbarPadding: EdgeInsets.only(left: 12),
             
                
                //chatFooterBuilder: , //for the 'typing' message
                inputTextStyle: TextStyle(fontSize: 15));
       
            }
            )
          )
    );
        }
  }

