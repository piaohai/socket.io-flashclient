package com.netease.pomelo
{
	import com.adobe.serialization.json.JSON;
	import com.netease.pomelo.EventManager;
	import com.netease.socket.PomeloSocket;
	import com.netease.websocket.MessageEvent;
	import com.netease.websocket.SocketService;
	import com.netease.websocket.web.WebsocketTransport;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.effects.easing.Back;

	public class Pomelo extends EventDispatcher
	{
		protected var eventManager:EventManager;
 		protected var requestId:int;
		protected var host:String;
		protected var port:int;
		protected var client:Object = null;
 
		public function Pomelo(host:String,port:uint,type:String):void {
			this.host = host;
			this.port = port;
			switch (type) {
				case WebsocketTransport.TRANSPORT_TYPE:
					client = new SocketService();
					break;
				case PomeloSocket.TRANSPORT_TYPE:
					client = new PomeloSocket(host,port);
					break;
				default :
					break;
			}
		}
		
		public function receviceMessage(event:MessageEvent):void {
 			 var data:Object = event.message;
			 if(data instanceof Array) {
				 this.processMessageBatch(data);
			 } else {
				 this.processMessage(data);
			 }
		}
		// Processes the message and invoke callback or event.
		protected function processMessageBatch(messages:Object):void {
			for(var i:int = 0; i < messages.length; i++) {
				this.processMessage(messages[i]);
			}
		}
 
		protected function processMessage(message:Object):void {
			if (message.id) {
				this.eventManager.invokeCallBack(message);
			} else { 
 				this.eventManager.dispatchEvent(message.route, message);
			}
		}
		
		public function connect():void {

			if (client!=null) {
				client.connect(host,port);
				this.requestId = 1;
				this.eventManager = new EventManager();
			}
			this.client.addEventListener('onmessage',this.receviceMessage);
		}
		
		// Request message from server and register callback.
		public function request(route:String, message:Object, action:Function):void {
 			this.requestId++;
			this.eventManager.addCallback(requestId, action);
			this.client.sendMessage(requestId, route, message);
		}
		
		// Notify message to server.
		public function notify(route:String, message:Object):void {
			this.client.sendMessage(0, route, message);
		}
		
 		public function on(eventName:String, action:Function):void {
			this.eventManager.addEventHandler(eventName, action);
		}
		
	}
}