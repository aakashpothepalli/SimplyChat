
/**
 * PROGRAM FLOW
 * when the user launches the app
 * myWebSocket will be initialized as a provider from the man function
 * The constructor calls [connectSocketIO] function which initializes a socket io port 
 * listeners for various channels are created 
 * All the chats of the user is obtained from [getChats] channel
 * 
 * When the [chatsPage] is initialized , [connect2room] is called for each of the [chatsLists] item
 * 
 * 
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'ChatPage/dashChatEdit/dash_chat.dart';


//websocket provider class
class MyWebsocket extends ChangeNotifier  {
  IO.Socket socket;
  var chatsList=[] ;//stores the chats from the server
  String latestMessage='{"sender":"","roomId":"","message":""}';
  Map<String,List<ChatMessage>> _messages = new Map(); //roomid,list of _messages 
  Map<String,int> unReadmessagesCount= new Map(); //count of all the unread _messages
  SharedPreferences prefs ; //storing _messages
  Map<String,String> headerStatus = new Map(); //stores online ,typing
  ScrollController chatViewScrollController = new ScrollController(initialScrollOffset: 0.0);


  
  //websocket will be initialized in the main function
  MyWebsocket(){
    connectSocketIO();
  }
  
  

 Map<String,List<ChatMessage>> get messages =>Map<String,List<ChatMessage>> .unmodifiable(_messages);

   void connectSocketIO() async {
      this.socket = IO.io('https://simply-chat-nodeapp.glitch.me', <String, dynamic>{
        'transports': ['websocket'],
      });
      
    socket.on('connect', (_) {
      print('connected');
     
    });

    socket.on('disconnect', (_){
      print('disconnected');
    });

     socket.on('getChats',getChatsOnComplete);
      socket.on('dm',dmChannel);

    socket.on('isTyping',checkIfUserIsTyping);
   }

  void auth(FirebaseUser user){
    send('auth','{"uid":"${user.uid}","profilePic":"${user.photoUrl}","profileName":"${user.displayName}"}');
  }

  send(channel,text) async{   
    this.socket.emit(channel,text);
  }

  Future<void> loadChatmessagesFromLocalStorage(String roomId) async {
    this.prefs = await SharedPreferences.getInstance();

    List<dynamic> ms = json.decode(prefs.getString(roomId))[roomId] ??[];

    print(ms[0]['createdAt']);
    for(var m in ms){
      // print(m);
      ChatMessage cm = ChatMessage(
        id: m['id'],
        text: m['text'],
        video: m['video'],
        image: m['image'],
        // createdAt: ,
        user: ChatUser(
          avatar:m['user']['avatar'],
          name: m['user']['name'],
          uid: m['user']['uid']),
        quickReplies: m['quickReplies']);
      this._messages[roomId].add(cm);
    }
    
  }
  ///wrapper function for requesting [getChats]
  void getChats(myUid){
//
    String message   ='{"uid":"$myUid"}';
    send('getChats',message);
  }

  ///callback function for updating the state of [chatsList] once the data is received from the server
  void getChatsOnComplete(data)async{
      var chats = json.decode(data);
      print(data);
      this.chatsList  = chats;
      for(int i=0;i<chats.length;i++){
        this._messages[chats[i]['roomId']] = new List<ChatMessage>();
        await loadChatmessagesFromLocalStorage(chats[i]['roomId']);
        this.unReadmessagesCount[chats[i]['roomId']] =0;
        this.headerStatus[chats[i]['roomId']]=" ";
      //  this.latest_messages[chats[i]['roomId']] = "";
      }
      Queue<String> q=new Queue();
      
      notifyListeners();
  }
  
  ///callback function for handling all the dm's 
  void dmChannel(data){
      var jsonMessage = jsonDecode(data);
      print('dm channel: ' +data);
      // this.latestMessage = data;
      if(this.chatViewScrollController.hasClients )
        this.chatViewScrollController.jumpTo(chatViewScrollController.position.maxScrollExtent+50);///scroll to bottom if any message is recieved

      ChatMessage cm = ChatMessage(
        text: jsonMessage['message'],
        createdAt:jsonMessage['createdAt']??new DateTime.now(),
        user: ChatUser(
          name: jsonMessage['profileName']??"aakash",
          uid: jsonMessage['sender'],
          
        ),
      );
      this.unReadmessagesCount[jsonMessage['roomId']] +=1;
      var temp = this._messages;
      temp[jsonMessage['roomId']].add(cm);
      this._messages =temp;
      // this.latest_messages[jsonMessage['roomId']] = jsonMessage['message'];
      
      notifyListeners();
  }

  //wrapper function for sending a message 
  void sendMessage(myUid,roomId,chatMessage){
    String data = '{"sender":"$myUid","roomId":"$roomId","message":"${chatMessage.text}"}';
    send('dm',data);
    _messages[roomId].add(chatMessage);
    this.prefs?.setString(roomId, json.encode(this._messages));///save message to local server
    notifyListeners();
  }

  ///[connect2room] is called when the chatsList is loaded
  /// each chat is associated with roomId 
  /// the roomId is sent to the server and the server adds the client to the room

  void connect2room(roomId,myUid){
      // print('connecting...');
      send('connect2room',roomId);    

   }

   void messagesRead(roomId){
     unReadmessagesCount[roomId]=0;
     notifyListeners();
   }
  
  void checkIfUserIsTyping(data){
    var jsonMessage = jsonDecode(data);
    print(data);
    if(jsonMessage['message']=='typing'){
      print('typing');
      headerStatus[jsonMessage['roomId']] ="Typing...";
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 1500), () {

      headerStatus[jsonMessage['roomId']] =" ";
      notifyListeners();
      });

    }
  }

  

}


