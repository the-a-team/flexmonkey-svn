package com.gorillalogic.flexmonkey
{
	import flash.events.Event;

	public class MonkeyEvent extends Event {
		
		public static const READY_FOR_VALIDATION:String = "readyForValidation";
		
		public function MonkeyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
} 