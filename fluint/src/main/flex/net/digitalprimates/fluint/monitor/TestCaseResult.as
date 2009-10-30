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
package net.digitalprimates.fluint.monitor {
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.utils.ResultDisplayUtils;

	/** 
	 * This class contains result information about the execution of a test case. 
	 * 
	 * The TestMonitor class uses instances of this class to maintain state and 
	 * display information for each TestCase. 
	 */  
	public class TestCaseResult extends EventDispatcher implements ITestResultContainer {
        /**
         * @private
         */
		protected var _children:ArrayCollection = new ArrayCollection();
		
		/** 
		 * A human readable name for this class derived from the class name and 
		 * path. 
		 */
		protected var displayName:String;

		/** 
		 * An internal status variable for this class that is added with the status 
		 * variables from child TestMethodResult to determine an overall status. 
		 * This variable is false when an entire TestCase is deemed invalid, likely 
		 * when a setup or teardown fails.
		 */
		protected var caseStatus:Boolean = true;

        /**
         * @private
         */
		private var _executed:Boolean = false;

        /**
         * @private
         */
		private var testCase:TestCase;

		/** 
		 * Boolean value that indicates if this case has been executed yet. 
		 */
		public function get executed():Boolean {
			return _executed;
		}
		
        /**
         * @private
         */
		public function set executed( value:Boolean ):void {
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'executed', _executed, value );
			_executed = value;
			dispatchEvent( propertyChangedEvent );
		}

        /**
          * Used to expose the qualifiedClassName of the testcase for reporting
		  **/
		public function get qualifiedClassName() : String
		{
			return getQualifiedClassName(testCase);
		}

        /**
         * @private
         */
		protected var _status:Boolean = true;

		/** 
		 * Stack trace information captured by a failing TestCase.
		 */
		public var traceInformation:String;

		/** 
		 * A count of the number of failures in the TestMethods 
		 * represented by the children of this class.
		 */
		public function get numberOfFailures():int {
			var count:int = 0;

			for ( var i:int; i<children.length; i++ ) {
				if ( children[i].failed ) {
					count++;
				}
			}

			return count;
		}

		/** 
		 * A count of the number of errors in the TestMethods 
		 * represented by the children of this class.
		 */
		public function get numberOfErrors():int {
			var count:int = 0;

			for ( var i:int; i<children.length; i++ ) {
				if ( children[i].errored ) {
					count++;
				}
			}

			return count;
		}
		
		/**
		 * A count of the totalTime in the TestMethods 
		 * represented by the children of this class.
		 **/
		 public function get totalTime() : int
		 {
		 	var total:int = 0;
		 	
			for ( var i:int; i<children.length; i++ ) {
				total += children[i].testDuration;
			}

			return total;
		 }

		/** 
		 * An ArrayCollection that holds instances of the TestMethodResult class. 
		 */
		public function get children():ArrayCollection {
			return _children;
		}

        /**
         * @private
         */
		public function set children( value:ArrayCollection ):void {
			_children = value;
		}

		[Bindable('propertyChanged')]
		/** 
		 * Returns a single pass or fail status for all methods represented by the 
		 * children of this class. 
		 */
		public function get status():Boolean {
			_status = caseStatus;

			if ( _status ) {
				for ( var i:int; i<children.length; i++ ) {
					_status &&= Boolean( children[i].status ); 
				}
			}

			return _status;
		}

        /**
         * @private
         */
		public function set status( value:Boolean ):void {
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'status', _status, _status );
			caseStatus = value;
			propertyChangedEvent.newValue = status;
			dispatchEvent( propertyChangedEvent );
		}

		/** 
		 * Adds an instance of the TestMethodResult class as a child of this class. 
		 * 
		 * @param testMethodResult An instance of the TestMethodResult class.
		 */
		public function addTestMethodResult( testMethodResult:TestMethodResult ):void {
			children.addItem( testMethodResult );
		}
	
		/**
		 * Change handler that watches children for a change in their status.
		 * 
		 * @param event The event dispatch when the children collection changes.
		 */
		protected function handleTestMethodsChange( event:CollectionEvent ):void {
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'status', _status, _status );
			
			propertyChangedEvent.newValue = status;
			dispatchEvent( propertyChangedEvent );
		}

		/** 
		 * Provides a human readable representation of this class, including 
		 * name and status. 
		 * 
		 * @inheritDoc
		 */
		override public function toString():String {
			return ResultDisplayUtils.toString( displayName, status, executed );
		}

		/** 
		 * Constructor. 
		 * 
		 * @param testCase The TestCase represented by this TestCaseResult class. 
		 */
		public function TestCaseResult( testCase:TestCase ) {
			this.testCase = testCase;
			displayName = ResultDisplayUtils.createSimpleClassName( testCase );
			children.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleTestMethodsChange );
		}
	}
}