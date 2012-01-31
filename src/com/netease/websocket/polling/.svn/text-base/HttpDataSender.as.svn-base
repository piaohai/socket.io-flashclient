package com.netease.websocket.polling
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/*
		Only one URLLoader uses to send data
	*/
	public class HttpDataSender extends EventDispatcher
	{
		private var _sendUrl:String;
		private var _busy:Boolean = false;
		private var _urlLoader:URLLoader;
		private var _requestHeaders:Array;
		private var _messageQueue:Array = new Array();
		
		public function HttpDataSender(sendUrl:String)
		{
			_sendUrl = sendUrl;
			_requestHeaders = new Array(
				new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8"),
				new URLRequestHeader("Pragma", "no-cache"),
				new URLRequestHeader("Cache-Control", "no-cache")); 
		}
		
		public function send(data:String):void
		{
			if (_busy)
			{
				_messageQueue.push(data);
				return;
			}
			
			if (_urlLoader == null)
			{
				_urlLoader = new URLLoader();
				_urlLoader.addEventListener(Event.COMPLETE, onSendCompleted);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onSendIoError);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSendSecurityError);
			}
			
			var urlRequest:URLRequest = new URLRequest(_sendUrl);
			urlRequest.method = URLRequestMethod.POST;
			//trace(unescape("%225%3A%3A%3A%7B%5C%22name%5C%22%3A%5C%22test%5C%22%2C%5C%22args%5C%22%3A%5B%7B%5C%22my%5C%22%3A%5C%22fsfsd%5C%22%7D%5D%7D%22"));
 			var urlVariables:URLVariables = new URLVariables("d="+escape(data));//%225%3A%3A%3A%7B%5C%22name%5C%22%3A%5C%22test%5C%22%2C%5C%22args%5C%22%3A%5B%7B%5C%22my%5C%22%3A%5C%22fsfsd%5C%22%7D%5D%7D%22
			urlRequest.data = urlVariables;
			urlRequest.requestHeaders = _requestHeaders; 
			_urlLoader.load(urlRequest);
			_busy = true;
		}
		
		public function close():void
		{
			if (_urlLoader)
			{
				_messageQueue = [];
				_urlLoader.removeEventListener(Event.COMPLETE, onSendCompleted);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSendIoError);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSendSecurityError);
				_urlLoader.close();
				_urlLoader = null;
			}
		}

		private function onSendCompleted(event:Event):void
		{
			_busy = false;
			if (_messageQueue.length == 0)
			{
				return;
			}
			var data:String = _messageQueue.pop();
			send(data);
		}
		
		private function onSendIoError(event:IOErrorEvent):void
		{
			dispatchEvent(event.clone());	
		}
		
		private function onSendSecurityError(event:SecurityErrorEvent):void
		{
			dispatchEvent(event.clone());	
		}
		
	}
}