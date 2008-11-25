package com.gorillalogic.flexmonkey.core
{
	import flash.events.Event;

	public class MonkeyEvent extends Event {
		
	/**
	* The MonkeyEvent.READY_FOR_VALIDATION constant defines the value of the 
	* <code>type</code> property of the event object 
	* for a <code>readyForValidation</code> event.
	 * 
	 * <p>This event is emitted whenever a <code>CommandRunner</code> finishes running a list of commands.</p>
	*
	*
	* @eventType readyForValidation
	*/	
		public static const READY_FOR_VALIDATION:String = "readyForValidation";
		
	/**
	* The MonkeyEvent.ERROR constant defines the value of the 
	* <code>type</code> property of the event object 
	* for a <code>readyForValidation</code> event.
	 * 
	 * <p>This event is emitted whenever a <code>CommandRunner</code> encounters an error running a list of commands.</p>
	*
	*
	* @eventType error
	*/	
		public static const ERROR:String = "error";	
		
		/**
		 * For ERROR events, contains the error message
		 */
		public var message:String;	
		
		public function MonkeyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, message:String=null)
		{
			this.message = message;
			super(type, bubbles, cancelable);
		}
		
	}
} 