/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.events
{
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	
	import flash.events.Event;

	public class RecorderEvent extends Event
	{
		public static const NEW_UI_EVENT:String = "newUIEvent";
		public static const NEW_SNAPSHOT:String = "newSnapshot";
		public static const RECORDER_STARTED:String = "recordStarted";
						
		public var command:UIEventMonkeyCommand;				
						
		public function RecorderEvent(type:String, command:UIEventMonkeyCommand = null,
			bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.command = command;
		}
	}
}