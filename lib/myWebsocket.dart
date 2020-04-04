
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
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;


//websocket provider class
class MyWebsocket extends ChangeNotifier {
  IO.Socket socket;
  var chatsList=[] ;//stores the chats from the server
  String latestMessage='{"sender":"","roomId":"","message":""}';
  Map<String,String> latestMessages = new Map();
  Map<String,Queue<String>> messages = new Map(); //roomid,queue of messages 
  //websocket will be initialized in the main function
  MyWebsocket(){
    connectSocketIO();
  }

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
   }


  send(channel,text) async{   
    this.socket.emit(channel,text);
  }

  ///wrapper function for requesting [getChats]
  void getChats(myUid){

    String message   ='{"uid":"$myUid"}';
    send('getChats',message);
  }

  ///callback function for updating the state of [chatsList] once the data is received from the server
  void getChatsOnComplete(data){
      var chats = json.decode(data);
      print(data);
      this.chatsList  = chats['chats'];
      for(int i=0;i<chats['chats'].length;i++){
       this.messages[chats['chats'][i]['roomId']] = new Queue<String>();
       this.latestMessages[chats['chats'][i]['roomId']] = "";
      }
      Queue<String> q=new Queue();
      
      notifyListeners();
  }
  
  ///callback function for handling all the dm's 
  void dmChannel(data){
      var jsonMessage = jsonDecode(data);
      print('dm channel: ' +data);
      this.latestMessage = data;
      this.messages[jsonMessage['roomId']].add(data);
      this.latestMessages[jsonMessage['roomId']] = jsonMessage['message'];
      notifyListeners();
  }

  //wrapper function for sending a message 
  void sendMessage(myUid,roomId,message){
    String data = '{"sender":"$myUid","roomId":"$roomId","message":"$message"}';
    send('dm',data);
  }

  ///[connect2room] is called when the chatsList is loaded
  /// each chat is associated with roomId 
  /// the roomId is then sent to the server and the server adds the client to the room

  void connect2room(roomId,myUid){
    
      send('connect2room',roomId);    

   }

}


