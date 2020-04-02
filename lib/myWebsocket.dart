import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

//websocket provider class
class MyWebsocket extends ChangeNotifier {
  bool isSocketConnected = false;
  var data=[]; 
  WebSocket socket;
  Queue<String> messageQueue = new Queue<String>();// for sending messages to server
  var chatsList=[] ;//stores the chats from the server

  //websocket will be initialized in the main function
  MyWebsocket(){
    connect();
    checkQueue();
  }

  checkQueue(){
    /**for every 100 ms [messageQueue] is checked for any message's . 
     * if any message exists and the socket is active ,the message is sent to the server
     * if the socket is not able to send the message then try to connect
     * **/
    const oneSec = const Duration(milliseconds:100);
    new Timer.periodic(oneSec, (Timer t) {
      if( this.socket!=null && this.isSocketConnected==true){

        if(!this.messageQueue.isEmpty){
          this.socket.add(this.messageQueue.first);
          this.messageQueue.removeFirst();
          }

      }

    });
  }
  
  void connect()async{
    
    this.isSocketConnected =false; //when the connection is closed

    Future<WebSocket> socket = WebSocket.connect("wss://simply-chat-nodeapp.glitch.me/");

    socket.then((ws){
      this.socket = ws;
      this.isSocketConnected =true;

      //listens for any new data
      ws.listen(onData,onError:onError, onDone:connect); //tries to connect when the connection is lost
      
    });

  }

 
  /// add the message to [messageQueue]
  send(text) async{      
    messageQueue.add(text);
  }
  //callback when a connection error occurs
  void onError(error){
    print(error);

    connect();
  }
  //callback when data is recieved
  void onData(dynamic data){

      var res = jsonDecode(data);  /// receive the data from server and convert it into json
     print(res);
      if(res['channel']=="getChats"){
        this.chatsList =res['chats'];
          notifyListeners();

      }
  }
     
}
