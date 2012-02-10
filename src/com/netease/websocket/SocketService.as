package com.netease.websocket
{
	
	import com.adobe.serialization.json.JSON;
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

		public static const ONMESSAGE:String = "onmessage";
		
  		public function connect():void {
			_ioSocket = _socketIOTransportFactory.createSocketIOTransport(WebsocketTransport.TRANSPORT_TYPE, "localhost:8081/socket.io/1");
			_ioSocket.addEventListener(SocketIOEvent.CONNECT, onSocketConnected);
			_ioSocket.addEventListener(SocketIOEvent.DISCONNECT, onSocketDisconnected);
			_ioSocket.addEventListener(SocketIOEvent.MESSAGE, onSocketMessage);
			_ioSocket.addEventListener(SocketIOErrorEvent.CONNECTION_FAULT, onSocketConnectionFault);
			_ioSocket.addEventListener(SocketIOErrorEvent.SECURITY_FAULT, onSocketSecurityFault);
			_ioSocket.connect();
		}
		
		private function onSocketConnected(event:SocketIOEvent):void
		{
			onReceiveMessage("Connected" + event.target);
		}
		
		
		private function onSocketMessage(event:SocketIOEvent):void
		{
			
			onReceiveMessage(JSON.encode(event.message));
		}

		private function onReceiveMessage(message:String):void
		{
			var event:MessageEvent = new MessageEvent(ONMESSAGE,message);
			Application.application.stage.dispatchEvent(event);
 		}
	
		private function onSocketConnectionFault(event:SocketIOErrorEvent):void
		{
			onReceiveMessage(event.type + ":" + event.text);
		}
		private function onSocketSecurityFault(event:SocketIOErrorEvent):void
		{
			onReceiveMessage(event.type + ":" + event.text);
		}
		
		private function onSocketDisconnected(event:SocketIOEvent):void
		{
			onReceiveMessage("Disconnected" + event.target);
		}
		
		public function send(data:Object):void{
			_ioSocket.send(data);
		}
		
		public function disconnect():void{
			_ioSocket.disconnect();
		}
		 
	}
}