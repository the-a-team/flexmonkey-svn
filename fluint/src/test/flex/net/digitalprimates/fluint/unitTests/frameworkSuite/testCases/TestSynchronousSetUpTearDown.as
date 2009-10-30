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
package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
	import net.digitalprimates.fluint.tests.TestCase;

    /**
     * @private
     */
	public class TestSynchronousSetUpTearDown extends TestCase {
		protected var simpleValue:Number;
		protected var complexObject:Object;
		protected var unitializedBySetup:Object;

		override protected function setUp():void {
			super.setUp();

			simpleValue = 5;
			complexObject = new Object();
			complexObject.key = 99;
		}
		
		override protected function tearDown():void {
			super.tearDown();

			simpleValue = -1;
			complexObject = null;
			unitializedBySetup = null;
		}
		
		/**
		 * These tests are a little different, we don't ever know the sequence
		 * that are tests will run, so each is going to do a little extra checking
		 * to ensure teardown did actually run 
		 */
	    public function testSetupCreatedComplexObj() : void {
	    	testTearDownDidNotAllowPersist();
	    	assertNotNull( complexObject );
	    	testInitializeValueForTearDown();
	    }

	    public function testSetupCreatedSimpleVal() : void {
	    	testTearDownDidNotAllowPersist();
	    	assertEquals( simpleValue, 5 );
	    	testInitializeValueForTearDown();
	    }

	    public function testInitializeValueForTearDown() : void {
	    	unitializedBySetup = new Object();
	    }

	    public function testTearDownDidNotAllowPersist() : void {
	    	assertNull( unitializedBySetup );
	    }
	}
}