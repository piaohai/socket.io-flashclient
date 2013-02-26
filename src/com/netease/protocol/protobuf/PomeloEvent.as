package com.netease.protocol.protobuf
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class PomeloEvent extends Event
	{
		public var bytes:ByteArray;
		
		public function PomeloEvent(type:String)
		{
			super(type);
			//super(CHANGE, bubbles, cancelable);
		}
		
		
	}
}