/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.events
{
	import flash.events.Event;

	/**
	 * The MonkeyCommandRunnerEvent is the event object passed to the event listener 
	 * for MonkeyCommandRunner events.
	 * 
	 * 
	 */
	public class MonkeyCommandRunnerEvent extends Event
	{
		/**
		 * For a MonkeyCommandRunnerEvent.EXECUTE event, contains the currently executing MonkeyCommand.
		 * 
		 * 
		 */ 
		public var item:Object;
		
	    /**
	     *  The <code>MonkeyCommandRunnerEvent.EXECUTE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>execute</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
	     * 	   <tr><td><code>item</code></td><td>The currently executing MonkeyCommand.</td></tr>
	     * 
	     *  </table>
	     *
	     *  @eventType execute
	     */		
		public static const EXECUTE:String = "monkeyCommandRunnerExecute";
		
	    /**
	     *  The <code>MonkeyCommandRunnerEvent.COMPLETE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for a <code>complete</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
	     * 	   <tr><td><code>item</code></td><td>null</td></tr>
	     *  </table>
	     *
	     *  @eventType complete
	     */			
		public static const COMPLETE:String = "monkeyCommandRunnerComplete";
		
		/**
	     *  The <code>MonkeyCommandRunnerEvent.ERROR</code> constant defines the value of the
	     *  <code>type</code> property of the event object for a <code>error</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
	     * 	   <tr><td><code>item</code></td><td>null</td></tr>
	     *  </table>
	     *
	     *  @eventType error
	     */			
		public static const ERROR:String = "monkeyCommandRunnerError";
	
	    /**
	     *  Constructor.
	     *
	     *  @param type The event type; indicates the action that caused the event.
	     *
	     *  @param item For a MonkeyCommandRunnerEvent.EXECUTE event, contains the currently executing MonkeyCommand.
	     * 
	     *  @param bubbles Specifies whether the event can bubble up
	     *  the display list hierarchy.
	     *
	     *  @param cancelable Specifies whether the behavior
	     *  associated with the event can be prevented.
	     */		
		public function MonkeyCommandRunnerEvent(type:String, item:Object = null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
	}
}