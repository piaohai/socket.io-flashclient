package com.netease.protocol.protobuf
{
	import com.adobe.serialization.json.JSON;
	import com.netease.protobuf.Proto;
	import com.netease.protobuf.Utils;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	
	public class Encoder
	{
		public function Encoder()
		{
			
		}
		
		private function  encodeUInt32(n:uint):ByteArray {
			//var n:uint = parseInt(ns);
			if(isNaN(n) || n < 0){
				return null;
			}
			var bytes:ByteArray = Utils.newBytes();;
			while(n != 0){
				var tmp = n % 128;
				var next = Math.floor(n/128);
				
				if(next != 0)
					tmp = tmp + 128;
				//result.push(tmp);
				bytes.writeByte(tmp);
				n = next;
			}
			return bytes;
		}
		
		private function encodeSInt32(n):ByteArray{
			var n = parseInt(n);
			if(isNaN(n)){
				return null;
			}
			//console.log('n : %j, n<0 : %j, -n*2 : %j, -1 : %j',n, n<0, (-n)*2-1);
			n = n<0?(Math.abs(n)*2-1):n*2;
			
			//console.log(n);
			return this.encodeUInt32(n);
		}
		
		
		
		private function encodeFloat(float:Number):ByteArray{
			var bytes:ByteArray = Utils.newBytes();
			bytes.writeFloat(float);
			return bytes;
		}
		
		private function  encodeDouble(double:Number):ByteArray{
			var bytes:ByteArray = Utils.newBytes();
			bytes.writeDouble(double);
			//Utils.print(bytes);
			return bytes;
		}
		
		private function  encodeStr(str:String):ByteArray{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(str);
   			return bytes;
		}
		
		
		private function byteLength(str:String):uint{
			if(typeof(str) !== 'string'){
				return -1;
			}
			
			var length = 0;
			
			for(var i = 0; i < str.length; i++){
				var code = str.charCodeAt(i);
				length += codeLength(code);
			}
			
			return length;
		}
		
		
		private function codeLength(code):uint{
			if(code <= 0x7f){
				return 1;
			}else if(code <= 0x7ff){
				return 2;
			}else{
				return 3;
			}
		}
		
		public function encode(route:String,msg:Object,protos:Object){
			
			//Get protos from protos map use the route as key
			var protos = protos[route];
			
			//Check msg
			if(!checkMsg(msg, protos)){
				trace('check msg failed! msg : %j, proto : %j', msg, protos);
				return null;
			}
			
			//Set the length of the buffer 2 times bigger to prevent overflow
			var length = byteLength(JSON.encode(msg));
			//Init buffer and offset
			var buffer:ByteArray = Utils.newBytes();;
			var offset:uint = 0;
			trace('length : %j', length);
			if(protos!=null){
				offset = this.encodeMsg(buffer, offset, protos, msg);
				trace('offset' + offset);
  				return buffer;
			} else {
				return null;
			}
			return null;
		}
		
		public function checkMsg(msg, protos):Boolean{
			if(!protos){
				return false;
			}
			
			for(var name in protos){
				var proto = protos[name];
				
				//All required element must exist
				switch(proto.option){
					case 'required' : 
						if(typeof(msg[name]) === 'undefined'){
							//console.log('no property msg : %j, name : %j', msg[name], name);
							return false;
						}
					case 'optional' :
						if(null!=protos.__messages[proto.type]){
							if(null!=protos.__messages[proto.type]){
								checkMsg(msg[name], protos.__messages[proto.type]);
							}
						}
						break;
					case 'repeated' :
					//Check nest message in repeated elements
					if(null!=msg[name] && null!=protos.__messages[proto.type]){
						for(var i = 0; i < msg[name].length; i++){
							if(!checkMsg(msg[name][i], protos.__messages[proto.type])){
								return false;
							}
						}
					}
					break;
				}
			}
			
			return true;
		}
		
		private function encodeMsg(buffer, offset:uint, protos, msg):uint{
			for(var name in msg){
				trace(name);
				if(null!=protos[name]){
					var proto = protos[name];
					
					//console.error('encode proto : %j', proto);
					switch(proto.option){
						case 'required' :
						case 'optional' :
							//console.log('encode tag');
							offset = Utils.writeBytes(buffer, offset, encodeTag(proto.type, proto.tag));
							offset = encodeProp(msg[name], proto.type, offset, buffer, protos);
							//console.log('encode tag finish, value : %j', msg[name]);
							break;
						case 'repeated' :
							if(msg[name].length > 0){
								offset = encodeArray(msg[name], proto, offset, buffer, protos);
							}
							break;
					}
				}
			}
 
			return offset;
		}
		
		private function encodeProp(value:*, type:String, offset:uint, buffer:ByteArray, protos:Object):uint{
			trace(' type ' + type);
			switch(type){
				case 'uInt32':
					offset = Utils.writeBytes(buffer, offset, this.encodeUInt32(value));
					break;
				case 'int32' :
				case 'sInt32':
					offset = Utils.writeBytes(buffer, offset, this.encodeSInt32(value));
					break;
				case 'float':
					offset = Utils.writeBytes(buffer, offset, this.encodeFloat(value));
 					break;
				case 'double':
 					offset = Utils.writeBytes(buffer, offset, this.encodeDouble(value))
 					break;
				case 'string':
					//Encode length
					var tbs:ByteArray = new ByteArray();
					tbs.writeUTFBytes(value);
 					offset = Utils.writeBytes(buffer, offset, this.encodeUInt32(tbs.length));
					offset = Utils.writeBytes(buffer, offset, tbs);
					//write string
 					//console.log('encode string length : %j, str : %j', length, value);
					break;
				default :
					if(null!=protos.__messages[type]){
						//console.log('msg encode start, type :%j, value : %j, start : %j', type, value, offset);
						//Use a tmp buffer to build an internal msg
						var tmpBuffer:ByteArray = Utils.newBytes();
						var length:uint = 0;
						
						length = encodeMsg(tmpBuffer, length, protos.__messages[type], value);
						//Encode length
						offset = Utils.writeBytes(buffer, offset, this.encodeUInt32(length));
						//contact the object
						//tmpBuffer.copy(buffer, offset, 0, length);
						offset = Utils.writeBytes(buffer, offset, tmpBuffer);
						//buffer.Utils.writeBytes(tmpBuffer,offset,length);
						//offset += length;
						//console.log('msg encode finish, offset : %j', offset);
					}
					break;
			}
			
			return offset;
		}
		
		/**
		 * Encode reapeated properties, simple msg and object are decode differented
		 */
		private function encodeArray(array, proto, offset, buffer, protos):uint{
			if(Utils.isSimpleType(proto.type)){
				offset = Utils.writeBytes(buffer, offset, encodeTag(proto.type, proto.tag));
				offset = Utils.writeBytes(buffer, offset, this.encodeUInt32(array.length));
				for(var i = 0; i < array.length; i++){
					offset = this.encodeProp(array[i], proto.type, offset, buffer,protos);
				}
			}else{
				//console.log('encode array : %j', array);
				for(var i = 0; i < array.length; i++){
					offset = Utils.writeBytes(buffer, offset, encodeTag(proto.type, proto.tag));
					//console.log('encode array value : %j', array[i]);
					offset = this.encodeProp(array[i], proto.type, offset, buffer, protos);
				}
			}
			
			return offset;
 		}
		
		
		
		private function encodeTag(type, tag):ByteArray{
			trace(typeof(Utils.TYPES[type]));
			if(typeof(Utils.TYPES[type]) === 'undefined'){
				type = 'message';
			}
			return this.encodeUInt32(tag<<3|Utils.TYPES[type]);
		}
		
	}
}