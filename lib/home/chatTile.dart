import "package:flutter/material.dart";
import 'package:simplychat/ChatPage/chatPage.dart';

class ChatTile extends StatefulWidget {
  String profilePic;
  String profileName;
  String recentMessage;
  int messageCount;
  String profileUid;
  String roomId;
  String myUid;
  ChatTile({this.profileName,this.messageCount,this.profilePic,this.recentMessage,this.profileUid,this.myUid,this.roomId});
  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:CircleAvatar(backgroundImage: NetworkImage(widget.profilePic??"https://www.searchpng.com/wp-content/uploads/2019/02/Deafult-Profile-Pitcher.png")) ,
      title: Text(widget.profileName?? "user name"),
      subtitle: Text(widget.recentMessage ?? "How are you doing ?"),
      onTap: (){
        Navigator.push(context, new MaterialPageRoute(builder: (context)=>ChatPage(
          receiverUid: widget.profileUid,
          myUid:widget.myUid ,
          roomId: widget.roomId,
        ) ));
      },
      trailing: CircleAvatar(child : Text((widget.messageCount?? 0).toString()) )
    );
  }
}