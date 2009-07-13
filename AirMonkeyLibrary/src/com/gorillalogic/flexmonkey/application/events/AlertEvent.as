/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.events
{
	import flash.events.Event;

	public class AlertEvent extends Event	
	{
		public static const ALERT:String = "alert";
		
		public var title:String;
		public var messageTextPart1:String;
		public var messageTextPart2:String;
		
		public function AlertEvent(type:String, 
									title:String,
									messageTextPart1:String="",
									messageTextPart2:String="",
									bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.title = title;
			this.messageTextPart1 = messageTextPart1;
			this.messageTextPart2 = messageTextPart2;
		}
		
	}
}