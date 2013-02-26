import com.adobe.serialization.json.JSON;
import com.netease.pomelo.Pomelo;
import com.netease.socket.PomeloSocket;
import com.netease.websocket.ISocketIOTransport;
import com.netease.websocket.ISocketIOTransportFactory;
import com.netease.websocket.MessageEvent;
import com.netease.websocket.SocketIOErrorEvent;
import com.netease.websocket.SocketIOEvent;
import com.netease.websocket.SocketIOTransportFactory;
import com.netease.websocket.SocketService;
import com.netease.websocket.polling.XhrPollingTransport;
import com.netease.websocket.web.WebSocketEvent;
import com.netease.websocket.web.WebsocketTransport;

import flash.events.Event;
import flash.system.Security;
import flash.system.System;
import flash.utils.ByteArray;

import mx.core.Application;

private var socket:SocketService;
public static var client:Pomelo = null;

private function init():void {
	Security.allowDomain("*");
	client = new Pomelo('114.113.202.141',3066,WebsocketTransport.TRANSPORT_TYPE);
	client.connect();
}

//114.113.202.141 192.168.145.113

private function OnLogin():void {
 	var msg:Object =  {username: userName.text,rid: channel.text};
 	client.request("connector.entryHandler.enter",msg, function(data):void {
		for (var i in data.users){
			if (userName.text!=data.users[i]){
				userList.addItem({label:data.users[i],data:data.users[i]});
			}
		}
		userName.editable = false;
		channel.editable = false;
		join.enabled = false;
		client.on('onChat',function(data:Object):void {
			if (data.from == userName.text) {
				data.from = 'you';
			}
 			var msg = data.from + ' says to '+ data.target + ":" + data.msg + '\r';
			msgArea.text += msg;
		});
		client.on('onAdd',function(data:Object):void {
  			if (userName.text!=data.user){
				userList.addItem({label:data.user,data:data.user});
			}
		});
		client.on('onLeave',function(data:Object):void {
			var index:int = -1;
			for(var i=0;i<userList.length;i++){
				var u = userList.list.getItemAt(i);;
				if (u.data==data.user){
					index = i;
					break;
				}
			}
 			if (index!=-1)
 			userList.removeItemAt(index);
		});
	});
	
}

 
 

private function onSend():void
{
  	var data:Object =  {from: userName.text,target:users.value,rid: channel.text,content:msg.text};
	
 	client.request("chat.chatHandler.send",data, function(data):void {
		msg.text = "";
 	});
}






