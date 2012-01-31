import com.adobe.serialization.json.JSON;
import com.netease.websocket.ISocketIOTransport;
import com.netease.websocket.ISocketIOTransportFactory;
import com.netease.websocket.SocketIOErrorEvent;
import com.netease.websocket.SocketIOEvent;
import com.netease.websocket.SocketIOTransportFactory;
import com.netease.websocket.polling.XhrPollingTransport;
import com.netease.websocket.web.WebsocketTransport;

import flash.system.Security;



private var _socketIOTransportFactory:ISocketIOTransportFactory = new SocketIOTransportFactory();
private var _ioSocket:ISocketIOTransport;

private function init():void {
	Security.allowDomain("*");
}

private function onConnectClick():void
{
	_ioSocket = _socketIOTransportFactory.createSocketIOTransport(XhrPollingTransport.TRANSPORT_TYPE, "localhost:8081/socket.io/1");
	_ioSocket.addEventListener(SocketIOEvent.CONNECT, onSocketConnected);
	_ioSocket.addEventListener(SocketIOEvent.DISCONNECT, onSocketDisconnected);
	_ioSocket.addEventListener(SocketIOEvent.MESSAGE, onSocketMessage);
	_ioSocket.addEventListener(SocketIOErrorEvent.CONNECTION_FAULT, onSocketConnectionFault);
	_ioSocket.addEventListener(SocketIOErrorEvent.SECURITY_FAULT, onSocketSecurityFault);
	_ioSocket.connect();
}
private function onSocketConnectionFault(event:SocketIOErrorEvent):void
{
	logMessage(event.type + ":" + event.text);
}
private function onSocketSecurityFault(event:SocketIOErrorEvent):void
{
	logMessage(event.type + ":" + event.text);
}
private function onDisconnectClick():void
{
	_ioSocket.disconnect();
}
private function onSocketMessage(event:SocketIOEvent):void
{
	if (event.message is String)
	{
		logMessage(String(event.message));
	}
	else
	{
		logMessage(JSON.encode(event.message));
	}
}

private function onSendClick():void
{
	_ioSocket.send({name: "hi", args:[{name:"yph",myx:"fsfsd"}]});
}


private function onSocketConnected(event:SocketIOEvent):void
{
	logMessage("Connected" + event.target);
}

private function onSocketDisconnected(event:SocketIOEvent):void
{
	logMessage("Disconnected" + event.target);
}

private function logMessage(message:String):void
{
	textArea.text = message + "\n";
}