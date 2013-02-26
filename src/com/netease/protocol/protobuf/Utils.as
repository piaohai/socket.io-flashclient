package com.netease.protocol.protobuf
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	public class Utils
	{
		public static const  TYPES:Object =  {uInt32 : 0,sInt32 : 0,			int32 : 0,	double : 1,string : 2,float : 5}
		
		public function Utils(){
		}
		
		public static function  isSimpleType(type:String):Boolean{
			return ( type === 'uInt32' || 	type === 'sInt32' || type === 'int32' || type === 'uInt64' || type === 'sInt64' || type === 'float' ||	type === 'double');
		}
		
		public static function newBytes():ByteArray{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			return bytes;
		}
		
		public static function print(bytes:ByteArray){
			bytes.position = 0;
			var s:String = "";
			while ( bytes.bytesAvailable ) {
				( s+=bytes.readByte().toString(16) + ' ');
			}
			trace(s);
			bytes.position = 0;
		}
		
		public static function writeBytes(buffer:ByteArray, offset:uint, bytes:ByteArray):uint{
 			
			for(var i = 0; i < bytes.length; i++, offset++){
				buffer[offset] = bytes[i];
			}
			
			return offset;
		}
		
		public static function copyBytes(dest:ByteArray, doffset:uint, src:ByteArray,soffset:uint,length:uint):void{
			
			for(var i:uint = soffset; i < length; i++, soffset++,doffset++){
				dest[doffset] = src[i];
			}
   
 		}
	}
}