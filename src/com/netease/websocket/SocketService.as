package com.netease.websocket
{
	
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.netease.protocol.json.Protocol;
	import com.netease.websocket.ISocketIOTransport;
	import com.netease.websocket.ISocketIOTransportFactory;
	import com.netease.websocket.SocketIOErrorEvent;
	import com.netease.websocket.SocketIOEvent;
	import com.netease.websocket.SocketIOTransportFactory;
	import com.netease.websocket.polling.XhrPollingTransport;
	import com.netease.websocket.web.WebSocketEvent;
	import com.netease.websocket.web.WebsocketTransport;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	
	public class SocketService extends EventDispatcher {
		
		private var _socketIOTransportFactory:ISocketIOTransportFactory = new SocketIOTransportFactory();
		private var _ioSocket:ISocketIOTransport;
  		
		
		public static var protocol:Protocol = new Protocol();
		
  		public function connect(url:String,port:uint):void {
			//"114.113.202.141:3088/
			_ioSocket = _socketIOTransportFactory.createSocketIOTransport(WebsocketTransport.TRANSPORT_TYPE, url + ":"+port+"/socket.io/1");
			_ioSocket.addEventListener(SocketIOEvent.CONNECT, onSocketConnected);
			_ioSocket.addEventListener(SocketIOEvent.DISCONNECT, onSocketDisconnected);
			_ioSocket.addEventListener(SocketIOEvent.MESSAGE, onSocketMessage);
			_ioSocket.addEventListener(SocketIOErrorEvent.CONNECTION_FAULT, onSocketConnectionFault);
			_ioSocket.addEventListener(SocketIOErrorEvent.SECURITY_FAULT, onSocketSecurityFault);
			_ioSocket.connect();
		}
		
		private function onSocketConnected(event:SocketIOEvent):void
		{
 			dispatchEvent(new MessageEvent(WebSocketEvent.OPEN,event));	
		}
		
		private function onSocketMessage(event:SocketIOEvent):void
		{
			onReceiveMessage(JSON.encode(event.message));
		}

		private function onReceiveMessage(message:String):void
		{
 			var event:MessageEvent = null;
			if (message is String) {
				var msg:String = message;
				if (msg.indexOf(':::')==2) {
				   msg = message.substring(6,message.length-2)
				   var smsg = msg.replace(new RegExp("\\\\", "g"), "");
 				   var data:Object = JSON.decode(smsg);
				   event = new MessageEvent(WebSocketEvent.ONMESSAGE,data);
				   dispatchEvent(event);	
 				} 
			} else {
				event = new MessageEvent(WebSocketEvent.ONMESSAGE,message);
				dispatchEvent(event);
 			}
 		}
 
	
		private function onSocketConnectionFault(event:SocketIOErrorEvent):void
		{
 			dispatchEvent(new MessageEvent(WebSocketEvent.ERROR,event));	
		}
		
		private function onSocketSecurityFault(event:SocketIOErrorEvent):void
		{
			dispatchEvent(new MessageEvent(WebSocketEvent.ERROR,event));	
		}
		
		private function onSocketDisconnected(event:SocketIOEvent):void
		{
			dispatchEvent(new MessageEvent(WebSocketEvent.ERROR,event));	
		}
		
		public function send(data:Object):void{
			var msg =  {name: "message", args:[data]};
			_ioSocket.send(msg);
		}
 
		
		public function disconnect():void{
			_ioSocket.disconnect();
		}
		
		public function sendMessage(requestId:int, route:String, message:Object):void {
			var outputMessage:String;
			
			try {
				outputMessage = Protocol.encode(requestId, route, message);
			} catch(e:Error) {
				trace("Error using Protocol.encode:", e);
			}
			send(outputMessage);
		}
		
 		 
	}
}