package com.netease.websocket
{
	import flash.events.Event;

 	public class MessageEvent extends Event{
		
		protected var _message:Object; //event所带数据
 		
		public function MessageEvent(type:String, eventData:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._message = eventData;
		}

		public function get message():Object
		{
			return _message;
		}
 
	}
}