package com.netease.socket
{
	import com.adobe.serialization.json.JSON;
	import com.netease.protocol.protobuf.Decoder;
	import com.netease.protocol.protobuf.Encoder;
	import com.netease.protocol.protobuf.PomeloEvent;
	import com.netease.protocol.protobuf.Proto;
	import com.netease.protocol.protobuf.Protocol;
	import com.netease.protocol.protobuf.Utils;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	public class PomeloSocket extends Socket
	{
		private var callbackIdx:Number = 0;
		
		public static var TRANSPORT_TYPE:String = "socket";
		
		private var timer:Timer =  null;
		
		private var host:String;
		private var port:int;
		private var _isLogin:Boolean = false;
		private var _isConnect:Boolean = false;
		private var _isReadHead:Boolean = false;
		private var _prefixLen:uint = 3;
		private var _dataLen:uint = 0;
		
		protected var PKG_HANDSHAKE = 1;    // handshake package
		protected var PKG_HANDSHAKE_ACK = 2;    // handshake ack package
		protected var PKG_HEARTBEAT = 3;    // heartbeat package
		protected var PKG_DATA = 4;         // data package
		
		public static var protocol:Protocol = new Protocol();
 
		private function shakeHandler(event:PomeloEvent){
			var shake:Object = JSON.decode(Protocol.strdecode(event.bytes));
			trace('shakeHandler' + shake.sys.heartbeat); 
			timer = new Timer((shake.sys.heartbeat-1)*1000);
			sendAck();
			timer.addEventListener(TimerEvent.TIMER,heartBeatHandler);
			timer.start();
			heartBeatHandler(event);
		}
		
		private function heartBeatHandler(data:PomeloEvent){
			sendHeartBeat();
			trace('heartBeatHandler');
		}
		
		private function onDataHandler(data:PomeloEvent){
			trace('onDataHandler');
			
		}
		
		public function PomeloSocket(host:String=null, port:int=0) {
			super();
			this.host = host;
			this.port = port;		
			this.endian = Endian.LITTLE_ENDIAN;
 			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			addEventListener(PKG_HANDSHAKE, shakeHandler);
			addEventListener(PKG_HEARTBEAT, heartBeatHandler);
			addEventListener(PKG_DATA, onDataHandler);
		}
 
		
		private function socketDataHandler(event:ProgressEvent):void {
			parseData();
		}
		
		protected var bytes:ByteArray = new ByteArray();
		
		private function parseData():void {
			if(!connected) {
				trace('[parseData] socket has closed!');
				return;	        	
			}
			bytes.endian = Endian.LITTLE_ENDIAN;

			//readBytes(bytes, 0, bytesAvailable);
			//Utils.print(bytes);
			//var msg:Object = Protocol.decode(bytes);
			
			//var p:Proto = new Proto();
			//var d:Decoder = new Decoder(p.proto());
			//var dmsg:Object = d.decode(route,bytes);
			//trace(dmsg);
			//return;
			if(!this._isReadHead) {
				if(bytesAvailable < this._prefixLen) {
					return;
				}
				var header:ByteArray = new ByteArray();
				header.endian = Endian.BIG_ENDIAN;
				bytes[0] = readByte();
				bytes[1] = header[2] = readByte();
				bytes[2] = header[3] = readByte();
				this._isReadHead = true;
				header[1] = 0;
				header[0] = 0;
				this._dataLen = header.readInt();
			}
			
			if(this._isReadHead && bytesAvailable >= this._dataLen) {
				var tempByts:ByteArray = new ByteArray();
				readBytes(tempByts, 0, this._dataLen);
				Utils.writeBytes(bytes,bytes.length,tempByts);
				this._isReadHead = false;
				var msg:Object = Protocol.decode(bytes);
				//decode(bytes);
				//读出数据发送事件
				trace(msg.flag);
 				var event:PomeloEvent = new PomeloEvent(msg.flag);
				event.bytes = msg.buffer;
				dispatchEvent(event);
			}
			
			if(connected && this._isReadHead && bytesAvailable < this._prefixLen) {
				parseData();
			}
		} 
		
		
		
		public function logout():void {
			if(connected) {
				close();
			}
		}
		
		public function sendHeartBeat():void {
			var bytes:ByteArray = Protocol.encode(PKG_HEARTBEAT,Protocol.strencode(""));
 			sendBytes(bytes);
		}
		
		public function sendAck():void {
			var bytes:ByteArray = Protocol.encode(PKG_HANDSHAKE_ACK,Protocol.strencode(""));
 			sendBytes(bytes);
		}
		
		
		public function send2(route:String,msg:Object):void {
			var e:Encoder = new Encoder();
			var bytes:ByteArray = e.encode(route,msg,p.proto());
			bytes.position = 0;
			sendBytes(bytes);
		}
		
		private var id:uint = 0;
		
		public function send(route:String,msg:Object):void {
			//var e:Encoder = new Encoder();
			++id;
			var bytes:ByteArray = new ByteArray();//Protocol.encodeBody(id,route,Protocol.strencode(msg));
			//var bytes:ByteArray = e.encode(route,msg,p.proto());
			Utils.print(bytes);
			bytes.position = 0;
			var packet:ByteArray = Protocol.encode(PKG_DATA,bytes);
			Utils.print(packet);
			sendBytes(packet);
		}
		
		
		public function sendBytes(bytes:ByteArray):void {
			if(!connected){
				trace('[sendBytes] socket hasn\'t open!');	
				return;
			}
			bytes.endian = Endian.LITTLE_ENDIAN;
			writeBytes(bytes);
			flush();
		}
		
		public var handshakeBuffer:Object = {
			'sys':{
				'version':'1.1.1',
				'heartbeat':1
			},'user':{
				
			}
		}
		
		private function connectHandler(e:Event):void {
			if(_isConnect) {
				var bytes:ByteArray = Protocol.encode(PKG_HANDSHAKE,Protocol.strencode(handshakeBuffer));
 				writeBytes(bytes);
			}
 		}
		
		private function closeHandler(e:Event):void {
			 this._isLogin = false;
			 this._isConnect = false;
			 super.close();
 			trace('closeHandler');
		}
		
		private static var p:Proto = new Proto();
		
		protected var route:String = 'onMove';
		
		protected  function decode(bytes:ByteArray):void {
			var d:Decoder = new Decoder(p.proto());
			var dmsg:Object = d.decode(route,bytes); 
			dispatchEvent(new Event(route)); 	
		}
		
		
	}
	
}