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
	import flash.utils.getQualifiedClassName;
	
	import net.digitalprimates.fluint.utils.ResultDisplayUtils;
	
	public class TestResultReport
	{
		private var _suiteResults : Array;
		
		public function TestResultReport(suiteResults : Array)
		{
			this._suiteResults = suiteResults;
		}
		
		/** 
		 * Returns an XML representation of all the tests in this system. 
		 * 
		 * This data is intended to be consumed by external applications such 
		 * as CruiseControl.
		 */
		public function toXml() : XML
		{
			var tmpXML:XML = <testsuites/>
			
			var status : Boolean = true;
			var failures : int = 0;
			var errors : int = 0;
			var testCount : int = 0;
			
			for each( var suiteResult : TestSuiteResult in _suiteResults)
			{
				tmpXML.appendChild(getTestSuiteResultXml(suiteResult));
				
				if(status)
				{
					status = suiteResult.status; 
				}
				
				failures += suiteResult.numberOfFailures;
				errors += suiteResult.numberOfErrors;
				suiteResult.children.toArray().forEach(function (element:*, index:int, arr:Array) : void {
					testCount += element.children.length;
				});
			}
			
			tmpXML.@status = status;
			tmpXML.@failureCount = failures;
			tmpXML.@errorCount = errors;
			tmpXML.@testCount = testCount;
			
			return tmpXML;
		}
		
		/**
          * Returns a collect of <testsuite> tags for each test suite
		  **/
		private function getTestSuiteResultXml(suiteResult : TestSuiteResult) : XMLList
		{
			
			var methodList:XMLList = new XMLList();
			
			for each( var caseResult : TestCaseResult in suiteResult.children ) {
				methodList += getTestCaseResultXml(caseResult);				
			}
			
			return methodList;
		}
		
		/**
          * Returns a <testsuite> for each test case
		  **/
		private function getTestCaseResultXml(caseResult : TestCaseResult) : XML
		{
			var methodList:XMLList = new XMLList();
			
			for each(var methodResult : TestMethodResult in caseResult.children ) {
				var testCaseXML : XML = getTestMethodResultXml(methodResult);
				testCaseXML.@className = ResultDisplayUtils.createQualifiedClassNameWithDots(caseResult.qualifiedClassName);
				 
				methodList += testCaseXML;
			}
			
			var result:XML = <testsuite />;
			result.@name = ResultDisplayUtils.createQualifiedClassNameWithDots(caseResult.qualifiedClassName);
			result.@errors = caseResult.numberOfErrors;
			result.@failures = caseResult.numberOfFailures;
			result.@tests = methodList.length();
			result.@time = caseResult.totalTime / 1000;
			
			//No proprties to output, just needed for compliance
			result.appendChild( <properties/> );
			result.appendChild(methodList);

			return result;
		}
		
		/**
          * Returns a <testcase> for each test method
		  **/
		private function getTestMethodResultXml(methodResult : TestMethodResult) : XML
		{
			var result:XML = <testcase/>;
			result.@name = methodResult.displayName;
			result.@time = Number( methodResult.testDuration / 1000 );

			if ( !methodResult.status ) {
				var body:XML = null;
				
				if ( methodResult.failed ) {
					body = <failure/>;
				} else {
					body = <error />;
				}

				body.@message = methodResult.error.message;
				body.@type = getQualifiedClassName(methodResult.error);
				body.setChildren( methodResult.traceInformation );
	
				result.setChildren( body );
			}

			return result;
		}

	}
}