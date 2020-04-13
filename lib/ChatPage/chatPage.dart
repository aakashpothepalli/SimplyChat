import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplychat/myWebsocket.dart';
import 'package:tuple/tuple.dart';
import 'dashChatEdit/dash_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String receiverUid;
  final String roomId;
  String profilePic;
  String profileName;
  final myUid;
  ChatPage({this.receiverUid, this.myUid, this.roomId,this.profilePic,this.profileName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

    SharedPreferences prefs ;
    var myUid;
    var roomId;
    var uuid = Uuid();

  ScrollController chatViewScrollController = new ScrollController(initialScrollOffset: 0.0);
  TextEditingController textEditingController = new TextEditingController();
  @override
  void initState() {
    this.myUid = widget.myUid;
    this.roomId = widget.roomId;
        var socket = Provider.of<MyWebsocket>(context,listen:false);
    socket.messagesRead(widget.roomId);
    super.initState();
  }

  
  onSend(dynamic) async {
    var socket = Provider.of<MyWebsocket>(context,listen:false);

    ChatMessage chatMessage = ChatMessage(
      text: textEditingController.text,
      user: ChatUser(
        // avatar: widget.profilePic, //insert my profile pic here
        uid: widget.myUid),
      messageIdGenerator: uuid.v4,
      createdAt: DateTime.now(),
    );
    socket.sendMessage(widget.myUid,widget.roomId,chatMessage);
  }

  userIsTyping(){
    var socket = Provider.of<MyWebsocket>(context,listen:false);
    socket.send('isTyping',this.roomId);
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
                    radius: 20,
                    backgroundImage: NetworkImage(widget.profilePic ??"https://www.searchpng.com/wp-content/uploads/2019/02/Deafult-Profile-Pitcher.png")),
              ),
              SizedBox(width: 10,),
              Column(
                children: <Widget>[
                  Text(
                   widget.profileName?? "Loading",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  ),
                  Selector<MyWebsocket,Map<String,String>>(
                    
                    shouldRebuild: (previous, next) => previous == next,

                    selector:(context,socket)=>socket.headerStatus, 

                    builder:(context,headerStatus,widget){

                    return Text(headerStatus[this.roomId],  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),);
                  } ,
                  
                  )
                ],
              ),
            ],
          ),
        ),
    
        body: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Selector <MyWebsocket , Tuple3<Map<String,List<ChatMessage>>,dynamic Function(dynamic),ScrollController>>( 
            
            shouldRebuild: (previous, next) => previous.item1.length == next.item1.length,

            selector:(context,socket)=>Tuple3(socket.messages,socket.messagesRead,socket.chatViewScrollController),

            builder: (context,socketTuple ,widget) {
              
              //implement tuple111
       
              return  DashChat(
                textController: textEditingController,
                scrollController: socketTuple.item3,
                messages: socketTuple.item1[this.roomId],
                onTextChange:(text)=> userIsTyping(),
                alwaysShowSend: true,
                inputMaxLines: 5,
                showAvatarForEveryMessage: false,
                onSend: onSend,
                scrollToBottom: false,   
                scrollToBottomWidget: (){return Container();},
                timeFormat: DateFormat.Hm(),
                user: ChatUser(
                    name:"aakash",
                    uid: this.myUid,),
                inputToolbarPadding: EdgeInsets.only(left: 12),                
                inputTextStyle: TextStyle(fontSize: 15));
            },

            )
          )
    );
    
        }
  }

