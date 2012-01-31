package com.netease.websocket.web
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.netease.websocket.BaseSocketIOTransport;
	import com.netease.websocket.SocketIOErrorEvent;
	import com.netease.websocket.SocketIOEvent;
	
	public class WebsocketTransport extends BaseSocketIOTransport implements IWebSocketLogger
	{
		public static var TRANSPORT_TYPE:String = "websocket";
		private static var CONNECTING:int = 0;
		private static var CONNECTED:int = 1;
		private static var DISCONNECTED:int = 2;
		
 		private var _webSocket:WebSocket;
		private var _origin:String;
		private var _cookie:String;
		
		private var _status:int = DISCONNECTED;
		
		public function WebsocketTransport(hostname:String)
		{
			super("ws://" + hostname + "/" + TRANSPORT_TYPE);
			_origin = "http://" + hostname + "/";
 			if (ExternalInterface.available)
			{
				try 
				{
					_cookie = ExternalInterface.call("function(){return document.cookie}");
				}
				catch (e:Error)
				{
					trace(e);
					_cookie = "";					
				}
			}
			else
			{
				_cookie = "";
			}
		}
		
		public override function connect():void
		{
			if (_status != DISCONNECTED)
			{
				return;
			}
			var urlLoader:URLLoader = new URLLoader();
			var urlRequest:URLRequest = new URLRequest(_origin + "/?t=" + currentMills());
			urlLoader.addEventListener(Event.COMPLETE, onConnectedComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onConnectIoErrorEvent);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConnectSecurityError);
			_connectLoader = urlLoader;
			urlLoader.load(urlRequest);
		}
		
		private var _connectLoader:URLLoader;
		
		private function onConnectedComplete(event:Event):void
		{
			var urlLoader:URLLoader = event.target as URLLoader;
			var data:String = urlLoader.data;
			var connectEvent:SocketIOEvent = new SocketIOEvent(SocketIOEvent.CONNECT);
			_sessionId = decodeSid(data)[0];
			_connectLoader.close();
			_connectLoader = null;
			if (_sessionId == null)
			{
				// Invalid request
				var errorEvent:SocketIOErrorEvent = new SocketIOErrorEvent(SocketIOErrorEvent.CONNECTION_FAULT, "Invalid sessionId request");
				dispatchEvent(errorEvent);
				return;
			}
			_webSocket = new WebSocket(0, hostname+'/'+_sessionId, [], _origin , null, 0, _cookie, null, this);
			_webSocket.addEventListener(WebSocketEvent.OPEN, onWebSocketOpen);
			_webSocket.addEventListener(WebSocketEvent.MESSAGE, onWebSocketMessage);
			_webSocket.addEventListener(WebSocketEvent.CLOSE, onWebSocketClose);
			_webSocket.addEventListener(WebSocketEvent.ERROR, onWebSocketError);
			_status = CONNECTING;
			_isFirstMessage = true;
 		}
		
		private function onConnectIoErrorEvent(event:IOErrorEvent):void
		{
 			var socketIOErrorEvent:SocketIOErrorEvent = new SocketIOErrorEvent(SocketIOErrorEvent.CONNECTION_FAULT, event.text);
			dispatchEvent(socketIOErrorEvent);
		}
		
		private function onConnectSecurityError(event:SecurityErrorEvent):void
		{
 			var socketIOErrorEvent:SocketIOErrorEvent = new SocketIOErrorEvent(SocketIOErrorEvent.SECURITY_FAULT, event.text);
			dispatchEvent(socketIOErrorEvent);
		}
		
		
		public override function disconnect():void
		{
			if (_status == CONNECTED || _status == CONNECTING)
			{
				_webSocket.close();
			}
		}
		
		private function onWebSocketOpen(event:WebSocketEvent):void
		{
 			trace('connected ================send heartbeat=====================');
			send(('2:::'));
		}

		private function onWebSocketClose(event:WebSocketEvent):void
		{
			if (_status == CONNECTED || _status == CONNECTING)
			{
				_status = DISCONNECTED;
				_webSocket.removeEventListener(WebSocketEvent.OPEN, onWebSocketOpen);
				_webSocket.removeEventListener(WebSocketEvent.MESSAGE, onWebSocketMessage);
				_webSocket.removeEventListener(WebSocketEvent.CLOSE, onWebSocketClose);
				_webSocket.removeEventListener(WebSocketEvent.ERROR, onWebSocketError);	
				_webSocket = null;
				fireDisconnectEvent();
			}
		}
		
		private function onWebSocketError(event:WebSocketEvent):void
		{
			var errorEvent:SocketIOErrorEvent = new SocketIOErrorEvent(SocketIOErrorEvent.CONNECTION_FAULT, event.message);
			dispatchEvent(errorEvent);
		}
		
		private var _isFirstMessage:Boolean = true;
		
		private function onWebSocketMessage(event:WebSocketEvent):void
		{
			if (_status == DISCONNECTED)
			{
				return;
			}
			var message:String = (event.message);
			if (_isFirstMessage)
			{
				_isFirstMessage = false;
				//_sessionId = messages.pop();
				_status = CONNECTED;
				var connectEvent:SocketIOEvent = new SocketIOEvent(SocketIOEvent.CONNECT);
				dispatchEvent(connectEvent);
			}
 			processMessages(message);
		}
		
		public override function send(message:Object):void
		{
			if (_webSocket == null )
			{
				return; //|| _status != CONNECTED
			}
			// TODO Remove code duplication like in XhrPollingTransport
			var socketIOMessage:String;
			if (message is String)
			{
				socketIOMessage = encode([message], false);
			}
			else if (message is Object)
			{
				var jsonMessage:String = JSON.encode(message);
				socketIOMessage = encode([jsonMessage], true);
			}
			_webSocket.send(escape(socketIOMessage));
		}
		
		public function log(message:String):void
		{
			trace(message);
		}
		
		public function error(message:String):void
		{
			trace(message);
		}
	}
}