package com.netease.protocol.protobuf
{
	import com.adobe.serialization.json.JSON;
	
	import flash.utils.ByteArray;

	public class Proto
	{
		
		public   var protos:Object = {"onMove" : {"required uInt32 entityId" : 1,"message Path": {"message Test": {"required uInt32 a" : 1},"required uInt32 x" : 1,"required uInt32 y" : 2,"required Test c" : 3,"repeated Test tests" : 4},"repeated Path paths" : 2,"optional uInt32 speed" : 3,"required string speed1" : 4,"required double a" : 5 }};
		
		
		public function Proto(){
		}
		
		
		public  function proto():Object{
			return parse(protos);
			//bytes:ByteArray
			//var str:String =  bytes.readUTF();
			//return JSON.decode(str);
		}
 
		
		private function parse(protos:Object){
			var maps = {};
			for(var key in protos){
				maps[key] = parseObject(protos[key]);
			}
			
			return maps;
		}
		
		private function  parseObject(obj):Object {
			var proto = {};
			var nestProtos = {};
			var tags = {};
			
			for(var name in obj){
				var tag = obj[name];
				var params = name.split(' ');
				
				switch(params[0]){
					case 'message':
						if(params.length != 2)
							continue;
						nestProtos[params[1]] = parseObject(tag);
						continue;
					case 'required':
					case 'optional':
					case 'repeated':{
						//params length should be 3 and tag can't be duplicated
						if(params.length != 3 || !!tags[tag]){
							continue;
						}
						proto[params[2]] = {
							option : params[0],
							type : params[1],
							tag : tag
						}
						tags[tag] = params[2];
					}
				}
			}
			
			proto.__messages = nestProtos;
			proto.__tags = tags;
			return proto;	
		} 

	}
}