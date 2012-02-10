import com.adobe.serialization.json.JSON;
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

import mx.core.Application;

private var socket:SocketService;


private function init():void {
	Security.allowDomain("*");
	Application.application.stage.addEventListener(SocketService.ONMESSAGE,onMessage);
}


private function onConnectClick():void
{
	socket = new SocketService();
	socket.connect();
}


private function onMessage(event:MessageEvent):void{
 	if (event.message is String)
	{
		logMessage(String(event.message));
	}
	else
	{
		logMessage(JSON.encode(event.message));
	}
	
}
	

private function onDisconnectClick():void
{
	socket.disconnect();
}

private function onSendClick():void
{
	socket.send({name: "hi", args:[{name:"yph",myx:"fsfsd"}]});
}

private function logMessage(message:String):void
{
	textArea.text = message + "\n";
}