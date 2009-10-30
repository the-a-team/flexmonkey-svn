/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package net.digitalprimates.fluint.events {
	import flash.events.Event;
	
	import net.digitalprimates.fluint.monitor.TestMethodResult;

	/** 
	 * A ChooseTestMethodResultEvent is fired by the TestProgressBar when 
	 * the user clicks on a visual representation of a completed test. This 
	 * event allows the TestResultDisplay code to select the appropriate result 
	 * in the tree and display the stack trace information in the text area.
	 */
	public class ChooseTestMethodResultEvent extends Event {
		/** 
		 * A reference to an instance of the TestMethodResult class, 
		 * created to hold information about the executing test method. 
		 */
		public var testMethodResult:TestMethodResult;

		/**
         * @private
         */
		public static var CHOOSE_TEST_METHOD_RESULT:String = 'chooseTestMethodResult';

		/** 
		 * Constructor.
		 * 
		 * This class has all of the properties of the event class, in addition to the 
		 * testMethodResult property.
		 * 
    	 * @param type The event type; indicates the action that triggered the event.
    	 *
    	 * @param bubbles Specifies whether the event can bubble
    	 * up the display list hierarchy.
    	 *
    	 * @param cancelable Specifies whether the behavior
    	 * associated with the event can be prevented.
    	 * 
		 * @param testMethodResult An instance of the TestMethodResultClass.
		 */
		public function ChooseTestMethodResultEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, testMethodResult:TestMethodResult=null) {
			this.testMethodResult = testMethodResult;
			super(type, bubbles, cancelable);
		}

		/** 
		 * Called by the framework to facilitate any requisite event bubbling 
		 * 
		 * @inheritDoc
		 */
		override public function clone():Event {
		   return new ChooseTestMethodResultEvent( type, bubbles, cancelable, testMethodResult );
		}		
	}
}