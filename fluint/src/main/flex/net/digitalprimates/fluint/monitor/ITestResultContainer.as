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
	import mx.collections.ArrayCollection;
	
	/** 
	 * Interface implemented currently by TestSuiteResult, TestCaseResult. 
	 * 
	 * The interface guarantees the presence of the children and 
	 * numberOfFailures properties, which indicates the hierarchy of the 
	 * suites, cases and methods as well as indicate the number of methods 
	 * that have failed. 
	 */ 
	public interface ITestResultContainer extends ITestResult
	{
		/** 
		 * TestSuites contain TestCases. TestCases contain TestMethods.
		 * 
		 * This ArrayCollection in each of the implementing classes contains 
		 * the above named children. **/
		function get children():ArrayCollection;

		/** 
		 * Indicates the number of failures present in the children collection. 
		 */
		function get numberOfFailures():int;
		
		/** 
		 * Indicates the number of errors present in the children collection. 
		 */
		function get numberOfErrors():int;
	}
}