package com.netease.protocol.protobuf
{
	import com.adobe.serialization.json.JSON;
	
	import flash.utils.ByteArray;

	public class Protocol
	{
		public function Protocol()
		{
			
		}
		
 		public static var BODY_HEADER = 5;
		public static var HEAD_HEADER = 4;
 		
		public static function encode(flag:uint,srcBytes:ByteArray):ByteArray
		{
 			var buffer:ByteArray = new ByteArray();
			var index:uint = 0;
 			var index = 0;
			var length:uint = srcBytes.length;
			buffer[index++] = flag & 0xFF;
			buffer[index++] = length>>16 & 0xFF;
			buffer[index++] = length>>8 & 0xFF;
			buffer[index++] = length & 0xFF;
			Utils.writeBytes(buffer,index,srcBytes);
			Utils.print(buffer);
			return buffer;
		}
		
		public static function  strencode(msg:Object):ByteArray{
			var msgStr:String = JSON.encode(msg);
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(msgStr);
			return bytes;
		}
		
		public static function  strdecode(buffer:ByteArray):String{
 			return buffer.readUTFBytes(buffer.length);
		}
 
		public static function decode(buffer:ByteArray):Object{
			var flag = buffer[0];
			var length = buffer.length;
			var bytes:ByteArray = new ByteArray();
			Utils.copyBytes(bytes,0,buffer,HEAD_HEADER,buffer.length);
			var msg = {flag:flag,buffer:bytes};
			return msg;
		};
		
		/**
		 *
		 * pomele client message encode
		 *
		 * @param id message id;
		 * @param route message route
		 * @param msg message body
		 *
		 * return string message for websocket
		 *
		 */
		
		public static function encodeBody(id:uint,flag:uint,route:ByteArray,msg:ByteArray):ByteArray{
			if (route.length>255) { throw new Error('route maxlength is overflow'); }
			var buffer:ByteArray = new ByteArray();
			var index:uint = 0;
			var i:uint = 0;
			buffer[index++] = (id>>24) & 0xFF;
			buffer[index++] = (id>>16) & 0xFF;
			buffer[index++] = (id>>8) & 0xFF;
			buffer[index++] = id & 0xFF;
			buffer[index++] = flag & 0xFF;
			var routeLen:uint = 2;
			if (flag==0){
				routeLen = buffer[index++];
			}  
 			Utils.copyBytes(buffer,index,route,0,route.length);
			Utils.copyBytes(buffer,index,msg,0, msg.length);
			return buffer;
		};
		
		/**
		 *
		 * pomelo client message decode
		 * @param msg string data to decode
		 *
		 * return Object
		 */
		
		public static function decodeBody(buffer:ByteArray):Object {
 			var btLen:uint = buffer.length;
			var index = 0;
			var id = ((buffer[index++] <<24) | (buffer[index++])  << 16  |  (buffer[index++]) << 8 | buffer[index++]) >>>0; 
			var flag:uint = buffer[index++];
			var roteBytes:ByteArray = new ByteArray();
			var routeLen = 2;
			if (flag==0){
				routeLen = buffer[index++];
				Utils.copyBytes(roteBytes,0,buffer,index,routeLen);
			} else {
				Utils.copyBytes(roteBytes,0,buffer,index,routeLen);
			}
			index+=routeLen;
 			var bodyArray:ByteArray = new ByteArray();
			Utils.copyBytes(bodyArray,0,buffer,index,btLen-index);
 			return {'id':id,'route':roteBytes,'buffer':bodyArray};
		};
		
		
	}
}