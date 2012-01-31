package com.netease.websocket
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import com.netease.websocket.web.WebsocketTransport;
	import com.netease.websocket.polling.XhrPollingTransport;

	public class SocketIOTransportFactory implements ISocketIOTransportFactory
	{
		private var _transpors:Dictionary = new Dictionary();
		
		public function SocketIOTransportFactory()
		{
			_transpors[XhrPollingTransport.TRANSPORT_TYPE] = XhrPollingTransport;
			_transpors[WebsocketTransport.TRANSPORT_TYPE] = WebsocketTransport;
		}
		
		public function createSocketIOTransport(transportName:String, hostname:String):ISocketIOTransport	
		{
			return new _transpors[transportName](hostname);
		}
	}
}