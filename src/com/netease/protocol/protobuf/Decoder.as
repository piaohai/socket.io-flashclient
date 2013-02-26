package com.netease.protocol.protobuf
{
	import flash.utils.ByteArray;
	
	
	public class Decoder
	{
		
		private var offset:uint = 0;
		private var buffer:ByteArray = null;
		private var protos:Object = null;
		
		public function Decoder(protos:Object){
			this.protos = protos;
		}
		
		private function  decodeUInt32(bytes:ByteArray):uint{
			var n = 0;
			for(var i = 0; i < bytes.length; i++){
				var m = parseInt(bytes[i]);
				n = n + ((m & 0x7f) * Math.pow(2,(7*i)));
				if(m < 128)
					return n;
			}
			return n;
		}
 
		private function  decodeSInt32(bytes:ByteArray):uint{
			var n = this.decodeUInt32(bytes);
			var flag = ((n%2) === 1)?-1:1;
			n = ((n%2 + n)/2)*flag;
			return n;
		}
		
		private function  decodeFloat(bytes:ByteArray):Number {
			return bytes.readFloat();
		}
		
		private function  decodeDouble(bytes:ByteArray):Number {
			return bytes.readDouble();
		}
		
		private function decodeStr(bytes:ByteArray, offset, length):String{
			var b:ByteArray = Utils.newBytes();
			b.readBytes(bytes,offset,length);
			return b.readUTFBytes(length);
		}
		
		public function decode(route:String, buffer:ByteArray):Object {
			//Utils.print(buffer);
			this.offset = 0;
			this.buffer = buffer;
			var protos = this.protos[route];
 	        var msg:Object = {};
			if(null!=protos){
				return decodeMsg(msg, protos, buffer.length);
			}
			
			return null;
		}
 

			
		private function decodeMsg(msg, protos, length):Object{
			
			while(offset<length){
				//console.log('offset : %j, length : %j, head bytes : %j', offset, length, peekBytes());
				var head = getHead();
				var type = head.type;
				var tag = head.tag;
				
				var name = protos.__tags[tag];
	 
				switch(protos[name].option){
					case 'optional' :
					case 'required' :
						msg[name] = decodeProp(protos[name].type, protos);
						break;
					case 'repeated' :
						//console.log('decode array');
						if(!msg[name]){
							msg[name] = [];
						}
						decodeArray(msg[name], protos[name].type, protos);
						break;
				}
				}
			
				return msg;
			}
			
			/**
			 * Test if the given msg is finished
			 */
			public function isFinish(msg, protos):Boolean{
				//console.log('head : %j, tags : %j, result : %j', peekHead(), protos.__tags, !!protos.__tags[peekHead().tag]);
				return (!protos.__tags[peekHead().tag]);
			}
			/**
			 * Get property head from protobuf
			 */
			public function getHead():Object{
				var tag = this.decodeUInt32(getBytes());
				
				return {
					type : tag&0x7,
						tag	: tag>>3
				};
			}
			
			/**
			 * Get tag head without move the offset
			 */
			public function peekHead():Object{
				var tag = this.decodeUInt32(peekBytes());
				
				return {
					type : tag&0x7,
						tag	: tag>>3
				};
			}
			
			public function decodeProp(type, protos):Object {
 				switch(type){
					case 'uInt32':
						return this.decodeUInt32(getBytes());
						break;
					case 'int32' :
					case 'sInt32' :
						return this.decodeSInt32(getBytes());
						break;
					case 'float' :
						var float:Number = this.buffer.readFloat();
						offset += 4;
						return float;
						break;
					case 'double' :
						var double:Number = buffer.readDouble();
						offset += 8;
						return double;
						break;
					case 'string' :
						var length:uint = this.decodeUInt32(getBytes());
						var str:String =  buffer.readUTFBytes(length);
						offset += length;
						
						return str;
						
						break;
					default :
						//console.log('object type : %j, protos: %j', type, protos);
						if(null!=protos.__messages[type]){
							var length = this.decodeUInt32(getBytes());
							var msg = {};
							decodeMsg(msg, protos.__messages[type], offset+length);
							return msg;
						}
						break;
				}
				return null;
			}
			
			public function decodeArray(array:Array, type, protos):void{
				if(Utils.isSimpleType(type)){
					var length = this.decodeUInt32(getBytes());
					for(var i = 0; i < length; i++){
						array.push(decodeProp(type,protos));
					}
				}else{
					array.push(decodeProp(type, protos));
				}	
			}
			
		  	 
			
			public function getBytes(flag=false):ByteArray {
				var bytes:ByteArray = Utils.newBytes();
				var pos = this.offset;
				flag = flag || false;
				
				do{
					var b = this.buffer[pos];
					bytes.writeByte(b);
					pos++;
				} while(b > 128);
				
				if(!flag){
					this.offset = pos;
					this.buffer.position = this.offset;
				}
				return bytes;
			}
			
			public function peekBytes():ByteArray{
				return getBytes(true);
			}
		

	}
}