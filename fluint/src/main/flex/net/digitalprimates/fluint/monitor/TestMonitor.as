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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.tests.TestMethod;
	import net.digitalprimates.fluint.tests.TestSuite;

	/** 
	 * The TestMonitor class is a singleton that contains references to 
	 * all SuitesResults, CaseResults and MethodResults in the system.
	 * 
	 * TestCase calls methods within this class to report the results of 
	 * individual test methods. The UI monitors the contents of this class 
	 * to show a visualization to the user. 
	 */
	public class TestMonitor extends EventDispatcher {
		/** 
		 * A dictionary that maps TestSuites to TestSuiteResults.
		 */
		protected var testSuiteDictionary:Dictionary = new Dictionary( true );

		/** 
		 * A dictionary that maps TestCases to TestCaseResults.
		 */
		protected var testCaseDictionary:Dictionary = new Dictionary( true );

		/** 
		 * A dictionary that maps Functions to TestMethodResults.
		 */
		protected var testMethodDictionary:Dictionary = new Dictionary( true );

		[Bindable]
		/** 
		 * A collection of all testSuites being run by this interface.
		 */
		public var testSuiteCollection:ArrayCollection;

		[Bindable]
		/** 
		 * A total test count of all methods in all testcases in all testSuites.
         * 
         * @default 0
		 */
		public var totalTestCount:int = 0;

		[Bindable]
		/** 
		 * A total error count of all methods in all testcases in all testSuites. 
         * 
         * @default 0
		 */
		public var totalErrorCount:int = 0;

		[Bindable]
		/** 
		 * A total failure count of all methods in all testcases in all testSuites.
         * 
         * @default 0
		 */
		public var totalFailureCount:int = 0;

        /**
         * @private
         */
		//private static var instance:TestMonitor;

		/**
		 * Returns the single instance of the class. This was a singleton class.
		 *  This is deprecated now. Normal instances if this class are made as needed
		 */		
/* 		public static function getInstance():TestMonitor {
			if ( !instance ) {
				instance = new TestMonitor();
			}

			return instance;
		} */
		
		/**
		 * Creates a new instance of the TestSuiteResult class. 
		 * Adds it to the internal mappings and to the testSuiteCollection.
		 * 
		 * @param testSuite The TestSuite which is about to be run.
		 * @return An instance of the TestSuiteResult class.
		 */		
		public function createTestSuiteResult( testSuite:TestSuite ):TestSuiteResult {
			var testSuiteResult:TestSuiteResult = new TestSuiteResult( testSuite );

			testSuiteDictionary[ testSuite ] = testSuiteResult;
			testSuiteCollection.addItem( testSuiteResult );
			
			return testSuiteResult;
		}
		
		/**
		 * Returns the instance of the TestSuiteResult based on the TestSuite.
		 * 
		 * @param testSuite A TestSuite which has been run.
		 * @return An instance of the TestSuiteResult class.
		 */		
		public function getTestSuiteResult( testSuite:TestSuite ):TestSuiteResult {
			var testSuiteResult:TestSuiteResult;

			testSuiteResult = testSuiteDictionary[ testSuite ];		

			return testSuiteResult;
		}

		/**
		 * Creates a new instance of the TestCaseResult class. 
		 * 
		 * Adds it to the internal mappings and to the appropriate TestSuiteResult 
		 * instance.
		 * 
		 * @param testSuite The TestSuite which is about to be run.
		 * @param testCase The TestCase which is about to be run.
		 * @return An instance of the TestCaseResult class.
		 */		
		public function createTestCaseResult( testSuite:TestSuite, testCase:TestCase ):TestCaseResult {
			var testCaseResult:TestCaseResult = new TestCaseResult( testCase );

			testCaseDictionary[ testCase ] = testCaseResult;
			
			var testSuiteResult:TestSuiteResult = getTestSuiteResult( testSuite );
			testSuiteResult.addTestCaseResult( testCaseResult );	
			
			return testCaseResult
		}

		/**
		 * Returns the instance of the TestCaseResult based on the TestCase.
		 * 
		 * @param testCase A TestCase which has been run.
		 * @return An instance of the TestCaseResult class.
		 */		
		public function getTestCaseResult( testCase:TestCase ):TestCaseResult {
			var testCaseResult:TestCaseResult;

			testCaseResult = testCaseDictionary[ testCase ];

			return testCaseResult;
		}

		/**
		 * Creates a new instance of the TestMethodResult class. 
		 * 
		 * Adds it to the internal mappings and to the appropriate TestCaseResult 
		 * instance.
		 * 
		 * @param testCase The TestCase which is about to be run.
		 * @param testMethod The TestMethod which is about to be run.
		 * @return An instance of the TestMethodResult class.
		 */		
		public function createTestMethodResult( testCase:TestCase, testMethod:TestMethod ):TestMethodResult {
			var testMethodResult:TestMethodResult = new TestMethodResult( testMethod );

			testMethodDictionary[ testMethod ] = testMethodResult;
			
			var testCaseResult:TestCaseResult = getTestCaseResult( testCase );
			testCaseResult.addTestMethodResult( testMethodResult );
			
			return testMethodResult;
		}

		/**
		 * Returns the instance of the TestMethodResult based on the actual method.
		 * 
		 * @param method A method which has been tested.
		 * @return An instance of the TestMethodResult class.
		 */		
		public function getTestMethodResult( method:Function ):TestMethodResult {
			var testMethodResult:TestMethodResult;

			for ( var testMethod:* in testMethodDictionary ) {				
				if ( testMethod.method == method ) {
					testMethodResult = testMethodDictionary[ testMethod ];
					break;
				}
			}

			return testMethodResult;
		}

		[Bindable('xmlResultsChanged')]
		/** 
		 * Returns an XML representation of all the tests in this system. 
		 * 
		 * It does so by querying each TestSuiteResult's xmlResults. This 
		 * data is intended to be consumed by external applications such 
		 * as CruiseControl and Hudson
		 */
		public function get xmlResults():XML {
			var report : TestResultReport = new TestResultReport(testSuiteCollection.toArray());
			return report.toXml();
		}

		/** 
		 * Monitors the testSuiteCollection for changes and updates the 
		 * totalFailureCount and totalErrorCount property.
		 */
		protected function handleCollectionChanged( event:Event ):void {
			var failureCount:int = 0;
			var errorCount:int = 0;

			for ( var i:int=0; i<testSuiteCollection.length; i++ ) {
				failureCount += testSuiteCollection.getItemAt( i ).numberOfFailures;
				errorCount += testSuiteCollection.getItemAt( i ).numberOfErrors;
			}
			
			if ( totalFailureCount > 0 ) {
				//trace("break here");
			}
			
			totalFailureCount = failureCount;
			totalErrorCount = errorCount;
			
			//Notify any listeners to the XMLResults that they need to update
			dispatchEvent( new Event( 'xmlResultsChanged' ) );
		}

        /**
         * Constructor.
         */
		public function TestMonitor() {
			testSuiteCollection = new ArrayCollection();
			testSuiteCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChanged, false, 0, true );
		}
	}
}