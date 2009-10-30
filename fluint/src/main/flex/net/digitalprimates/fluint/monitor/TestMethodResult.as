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
package net.digitalprimates.fluint.monitor
{
	import flash.events.EventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	
	import net.digitalprimates.fluint.assertion.AssertionFailedError;
	import net.digitalprimates.fluint.tests.TestMethod;
	import net.digitalprimates.fluint.utils.ResultDisplayUtils;
	
	[Bindable]
	/** 
	 * This class contains result information about the execution of a test method. 
	 * 
	 * The TestMonitor class uses instances of this class to maintain state and 
	 * display information for each method in a test case. 
	 */  
	public class TestMethodResult extends EventDispatcher implements ITestResult
	{
		/** 
		 * A human readable name for this method. 
		 * 
		 * It is basically a string copy of the method name declared in ActionScript. 
		 */
		public var displayName:String;

		/** 
		 * Metadata associated with this test method
		 */
		public var metadata:XML;

		/** 
		 * Time in milliseconds required to complete this test.
		 */
		public var testDuration:int;

		/** 
		 * Boolean value that indicates if this method has been executed yet. 
		 */
		public var executed:Boolean = false;

		/** 
		 * Object value that, in the result of a failed test, indicates 
		 * if it was an error thrown by Flex including failed assertions. 
		 */
		private var _error : Error;

		/** 
		 * Stack tace information captured by a failing method.
		 */
		private var _traceInformation:String;
		
		public function get error() : Error	{
			return _error;
		}

		public function set error( value : Error ):void	{
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'status', status, value );
			_error = value;
			dispatchEvent( propertyChangedEvent );
		}

		public function get traceInformation() : String {
		   var trace : String = "";
			
		   if(_traceInformation) {
		      trace += _traceInformation + "\n";
		   }
			
		   if(_error)
		   {
	         trace += _error.getStackTrace();
				}

		   return trace;
			}

		public function set traceInformation(trace : String) : void {
		   _traceInformation = trace;
		}

		[Bindable('propertyChanged')]
		/** 
		 * Boolean that indicates if the method monitored by this class 
		 * instance failed or succeeded. 
		 */
		public function get status():Boolean {
			return !_error;
		}

		/**
		 * Denotes whether or not a TestMethod failed
		 **/
		public function get failed() : Boolean
		{
			return (_error && _error is AssertionFailedError);
		}
		
		/**
		 * Denotes whether or not a TestMethod errored
		 **/
		public function get errored() : Boolean
		{
			return (_error && !(_error is AssertionFailedError));
		}

		/** 
		 * Provides a human readable representation of the method monitored by 
		 * this class, including name and status.
		 * 
		 * @inheritDoc
		 */
		override public function toString():String {
			return ResultDisplayUtils.toString( displayName, status, executed, errored);
		}

		/** 
		 * Constructor. 
		 * 
		 * @param testMethod The method information represented by this class instance.
		 * @param status The status of the test.
		 * @param traceInformation The traceInformation for any failures.
		 */
		public function TestMethodResult( testMethod:TestMethod, error:Error=null, traceInformation:String=null ) {
			displayName = testMethod.methodName;
			this.error = error;
			this.traceInformation = traceInformation;
			this.metadata = testMethod.metadata;
		}
	}
}