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
package net.digitalprimates.fluint.ui {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.core.IMXMLObject;
	
	import net.digitalprimates.fluint.monitor.TestCaseResult;
	import net.digitalprimates.fluint.monitor.TestMonitor;
	import net.digitalprimates.fluint.monitor.TestSuiteResult;
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.tests.TestMethod;
	import net.digitalprimates.fluint.tests.TestSuite;
	import net.digitalprimates.fluint.utils.ClassSortUtils;

	/**
	 * The TestRunner class is responsible for ensuring every TestCase in every 
	 * TestSuite is executed and the results are aggragated 
	 */
	[Event(name="testsComplete",type="flash.events.Event")]
	public class TestRunner extends EventDispatcher implements IMXMLObject {
		public static const TESTS_COMPLETE:String = "testsComplete";
		
        /**
         * @private
         */
        protected var _testMonitor:TestMonitor;

		[Bindable('testMonitorChanged')]
        public function get testMonitor():TestMonitor {
        	return _testMonitor;
        }
        
        public function set testMonitor( value:TestMonitor ):void {
        	_testMonitor = value; 
        	dispatchEvent( new Event( 'testMonitorChanged' ) );
        }

        protected var _testEnvironment:TestEnvironment;

		[Bindable('testEnvironmentChanged')]
        public function get testEnvironment():TestEnvironment {
        	return _testEnvironment;
        }
        
        public function set testEnvironment( value:TestEnvironment ):void {
        	_testEnvironment = value; 
        	dispatchEvent( new Event( 'testEnvironmentChanged' ) );
        }

        /**
         * @private
         */
		protected var schedulerTimer:Timer;

        /**
         * @private
         */
		protected var testProgression:ArrayCollection;
        /**
         * @private
         */
		protected var progressCursor:IViewCursor;

        /**
         * @private
         */
		protected var _testSuite:TestSuite;
        /**
         * @private
         */
		protected var _testCase:TestCase;

        /**
         * @private
         */
		protected var _testMethod:TestMethod;

        /**
         * @private
         */
		protected var testSuiteCollection:ArrayCollection;
        /**
         * @private
         */
		protected var cursor:IViewCursor;

        /**
         * @private
         */
		protected var testCompleted:Boolean = true;

        /**
         * @private
         */
		protected var lastTestSuite:TestSuite;

        /**
         * @private
         */
		protected var lastTestCase:TestCase;

		/** 
		 * Convenience method for returning TestMonitor.xmlResults().
		 */
		public function get xmlResults():XML {
			return testMonitor.xmlResults;
		}

		/** 
		 * The current testSuite.
		 */
		protected function get testSuite():TestSuite {
			return _testSuite;
		}

        /**
         * @private
         */
		protected function set testSuite( value:TestSuite ):void {
			if ( _testSuite != value ) {
				lastTestSuite = testSuite;
				_testSuite = value;

				if ( value ) {
					testMonitor.createTestSuiteResult( value );
				}
				
				if ( lastTestSuite ) {
					var testSuiteResult:TestSuiteResult;
					testSuiteResult = testMonitor.getTestSuiteResult( lastTestSuite );
					
					if ( testSuiteResult ) {
						testSuiteResult.executed = true;
					}
				}
			}
		}

		/** 
		 * The current Test Case.
		 */
		protected function get testCase():TestCase {
			return _testCase;
		}

        /**
         * @private
         */
		protected function set testCase( value:TestCase ):void {
			if ( _testCase != value ) {
				lastTestCase = testCase;
				_testCase = value;

				if ( value ) {
					testMonitor.createTestCaseResult( testSuite, value );
					value.testMonitor = testMonitor;
					value.testEnvironment = testEnvironment; 
				}

				if ( lastTestCase ) {
					var testCaseResult:TestCaseResult;
					testCaseResult = testMonitor.getTestCaseResult( lastTestCase );
					
					if ( testCaseResult ) {
						testCaseResult.executed = true;
					}
				}

			}
		}

		/** 
		 * The current test method. 
		 */
		protected function get testMethod():TestMethod {
			return _testMethod;
		}

        /**
         * @private
         */
		protected function set testMethod( value:TestMethod ):void {
			if ( _testMethod != value ) {
				_testMethod = value;

				if ( value != null ) {
					testMonitor.createTestMethodResult( testCase, value );
				}
			}
		}

		/** 
		 * Returns the next test suite in the sequence.
		 */
		public function getNextTestSuite():TestSuite {
			var testSuite:TestSuite;
			if ( !cursor.afterLast && !cursor.beforeFirst ) {
				testSuite = cursor.current as TestSuite;
				cursor.moveNext();
				return testSuite;
			} 
			this.dispatchEvent(new Event(TESTS_COMPLETE));
			//trace("All done");
			return null;			
		}

		/** 
		 * Handles timer events allowing us to act like a mini-round-robin 
		 * scheduler and ensure we don't recurse too deep in the stack. 
		 * Each TestMethod starts anew. 
		 * 
		 * @param event Event broadcast by the schedulerTimer.
		 */
		protected function handleTimerTick( event:TimerEvent ):void {
			//Here we check to see if we are ready for the next test method to be executed.
			//This allows us to manage the stack depth by always starting a new test on a fresh stack.
			if ( testCompleted ) {
				testCompleted = false;
				setupSuiteCaseAndMethodProperties();
				progressCursor.seek( CursorBookmark.FIRST );
				handleTestProcess( null );
			}
		}

		private function wrapTestCase( value:TestCase ):TestSuite {
			var suite:TestSuite = new TestSuite();
			suite.addTestCase( value as TestCase );
			
			return suite;			
		}
		/** 
		 * Starts the testingProcess.
		 * 
		 * It can accept an ArrayCollection of TestSuites, an Array of TestSuites, a single 
		 * TestSuite, or a single TestCase
		 * 
		 * @param value An Object that can be a TestCase, a TestSuite, or an array of TestSuites.
		 */ 
		public function startTests( value:Object ):void {
			if ( value is Array ) {
				for ( var i:int=0; i<(value as Array).length; i++ ) {
					if ( !( value[ i ] is TestSuite ) ) {
						if ( value[ i ] is TestCase ) {
							value[ i ] = wrapTestCase( value[ i ] as TestCase );
						} else {
							//element of this array which is not a suite or a test case. perhaps some day we will handle nested arrays
							//but today throw an error
							throw new Error( "Element of provided array is neither a TestCase nor a TestSuite" );
						}
					}
				}

				testSuiteCollection = new ArrayCollection( value as Array );
			} else if ( value is TestSuite ) {
				testSuiteCollection = new ArrayCollection( new Array( value ) );
			} else if ( value is TestCase ) {
				testSuiteCollection = new ArrayCollection( new Array( wrapTestCase( value as TestCase ) ) );
			} else {
				throw new Error( "No Test or TestSuite Provided" );				
			}

			var sort:Sort = new Sort();
			sort.compareFunction = ClassSortUtils.testClassCompare;

			testSuiteCollection.sort = sort;
			testSuiteCollection.refresh();
			
			cursor = testSuiteCollection.createCursor();

			testMonitor.totalTestCount = getTestCount();

			schedulerTimer.start();
		}

		/** 
		 * Returns a count of all tests in the suites and test cases 
		 */
		public function getTestCount():int {
			var testCount:int = 0;

			for ( var i:int; i<testSuiteCollection.length; i++ ) {
				testCount += testSuiteCollection.getItemAt( i ).getTestCount();
			}
			
			return testCount;
		}

        /**
         * @private
         */
		protected function setupSuiteCaseAndMethodProperties():void {
			if ( !testSuite ) {
				while ( ( testSuite = getNextTestSuite() ) != null ) {
					while ( ( testCase = testSuite.getNextTestCase() ) != null ) {
						while ( ( testMethod = testCase.getNextTestMethod() ) != null ) {
							return;
						}
					}
				}
				return;
			}

			while ( ( testMethod = testCase.getNextTestMethod() ) == null ) {
				while ( ( testCase = testSuite.getNextTestCase() ) == null ) {
					testSuite = getNextTestSuite();
					if ( !testSuite ) {
						//we are all done
						schedulerTimer.stop();
						return;
					}					
				}
			}
		}

		/**
		 * Starts running the setup phase of a given test method 
		 */
		protected function runSetup():void {
			//trace( "Now Setting Up " + testMethod.methodName );
			
			testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testCase.runSetup();
		}

		/**
		 * Starts running the method phase of a given test method 
		 */
		protected function runTestMethod():void {
			//trace( "Now Running " + testMethod.methodName );
			testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testCase.runTestMethod( testMethod.method );
		}

		/**
		 * Starts running the teardown phase of a given test method 
		 */
		protected function runTearDown():void {
			//trace( "Now Tearing Down " + testMethod.methodName );
			testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testCase.runTearDown();
		}

		/**
		 * Advances through the three phases, setIp, method and tearDown of each test.
		 * 
		 * @param event Broadcast in different phases of the test process.
		 */
		protected function handleTestProcess( event:Event ):void {
			var f:Function;

			if ( testCase ) {
				testCase.removeEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false );
			}

			//get the current function to call
			f = progressCursor.current as Function;

			//move to the next function
			progressCursor.moveNext();

			//execute the function
			if ( ( f != null ) && ( testCase ) ) {
				f();
			}

			if ( progressCursor.afterLast && !testCase.hasPendingAsync) {
				//restart the process
				testCompleted = true;
			}
		}

		private var id:String;
		private var document:Object;
		public function initialized(document:Object, id:String):void {
			this.document = document;
			this.id = id;
		} 
        /**
         * Constructor.
         */
		public function TestRunner( monitor:TestMonitor=null ) {
			var progressionArray:Array = [ runSetup, runTestMethod, runTearDown ];
			testProgression = new ArrayCollection( progressionArray );
			progressCursor = testProgression.createCursor();
			
			schedulerTimer = new Timer( 5, 0 );
			schedulerTimer.addEventListener(TimerEvent.TIMER, handleTimerTick );
			
			if ( monitor ) {
				testMonitor = monitor; 
			} else {
				testMonitor = new TestMonitor();
			}
		}
	}
}