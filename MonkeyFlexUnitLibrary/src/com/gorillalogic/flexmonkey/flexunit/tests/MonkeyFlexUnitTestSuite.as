/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.flexunit.tests
{	
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.tests.TestSuite;

	public class MonkeyFlexUnitTestSuite extends TestSuite
	{
		public function MonkeyFlexUnitTestSuite()
		{
			super();
		}
		private var _context:MonkeyFlexUnitTestContext;
		public function get context():MonkeyFlexUnitTestContext{
			return _context;
		}
		public function set context(c:MonkeyFlexUnitTestContext):void{
			_context = c;
			var testCase:MonkeyFlexUnitTestCase;
			for ( var i:int; i<caseCollection.length; i++ ) {
				testCase = caseCollection.getItemAt( i ) as MonkeyFlexUnitTestCase;
				testCase.context = this.context;
			}
		}
		
		override public function addTestCase( testCase:TestCase ):void {
			super.addTestCase(testCase);
			MonkeyFlexUnitTestCase(testCase).context = context;
		}
	}
}