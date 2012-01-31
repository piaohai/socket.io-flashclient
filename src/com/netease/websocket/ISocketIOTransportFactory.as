package com.netease.websocket
{
	import flash.display.DisplayObject;

	public interface ISocketIOTransportFactory
	{
		function createSocketIOTransport(transportName:String, hostname:String):ISocketIOTransport;	
	}
}