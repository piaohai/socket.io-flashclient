package com.netease.websocket
{
	import com.adobe.serialization.json.JSON;
	import com.netease.websocket.web.WebsocketTransport;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.unescapeMultiByte;
	
	public class BaseSocketIOTransport extends EventDispatcher implements ISocketIOTransport
	{
		
		protected var _sessionId:String;
		
		private var _hostname:String;
		public static const FRAME:String = "~m~";
		  
		
		public function BaseSocketIOTransport(hostname:String)
		{
			_hostname = hostname;
		}
		
		public function get hostname():String
		{
			return _hostname;
		}
		
		public function send(message:Object):void
		{
		}
		
		public function connect():void
		{
		}
		
		public function disconnect():void
		{
		}
		
		public function currentMills():Number
		{
			return (new Date()).time;
		}
		
		private function getFirst(messages:String):String {
			if (messages && messages.length>0) {
				return messages.substr(0,1);
			} else{	
				return "";
			}
		}
		
		public function processMessages(message:String):void
		{
			if (getFirst(message)=='2') {
				send(('2:::'));
				
			} else if (getFirst(message)=='5') {
				var json:String = message.substring(4,message.length);
				var jsonObject:Object = JSON.decode(json);
				fireMessageEvent(jsonObject);
			}  else
			{
				fireMessageEvent(message);
			}
		}
		
		protected function fireMessageEvent(message:Object):void
		{
			var messageEvent:SocketIOEvent;
			messageEvent = new SocketIOEvent(SocketIOEvent.MESSAGE, message);
			dispatchEvent(messageEvent);
		}
		
		protected function fireDisconnectEvent():void
		{
			var disconnectEvent:SocketIOEvent = new SocketIOEvent(SocketIOEvent.DISCONNECT);
			dispatchEvent(disconnectEvent);
		}
		
		public function decodeSid(data:String, unescape:Boolean = false):Array{
			if (unescape)
			{
				data = unescapeMultiByte(data);
			}
			var messages:Array = [], number:*, n:*;
			do {
				//if (data.substr(0, 3) !== FRAME)
				//{
				//return messages;	
				//}
				//data = data.substr(3);
				number = "", n = "";
				var datas:Array = data.split(":");
				return datas;
				for (var i:int = 0, l:int = data.length; i < l; i++)
				{
					n = Number(data.substr(i, 1));
					if (data.substr(i, 1) == n){
						number += n;
					} else {
						data = data.substr(number.length + FRAME.length);
						number = Number(number);
						break;
					}
				}
				messages.push(data.substr(0, number));
				data = data.substr(number);
			} while(data !== "");
			return messages;
		}
		
		public function encode(messages:Array, json:Boolean):String{
			var ret:String = "";
			var message:String;
			for (var i:int = 0, l:int = messages.length; i < l; i++)
			{
				message = messages[i] === null || messages[i] === undefined ? "" : (messages[i].toString());
				if (json)
				{
					message = "5:::" + message;
				}
				if (this is WebsocketTransport) {
					ret +=message;
				}
				else {
					ret += message.replace(new RegExp('\"','g'),'\\\"');	
				}
			}
			if (this is WebsocketTransport) {
				return ret;
			}
			else {
				return '"'+ret + '"';
			}
		}
		
		public function get sessionId():String
		{
			return _sessionId;
		}

		public function set sessionId(value:String):void
		{
			_sessionId = value;
		}

;
		
		
	}
}