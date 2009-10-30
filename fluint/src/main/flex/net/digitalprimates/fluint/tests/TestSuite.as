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
package net.digitalprimates.fluint.tests
{
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	
	import net.digitalprimates.fluint.utils.ClassSortUtils;

	/** 
	 * TestSuite is extended by developers to create groups of similar TestCases.
	 * 
	 * A TestSuite contains (n) TestCases. It keeps the TestCases in a 
	 * collection and allows adding the TestCase instances, which will 
	 * be executed by the TestRunner code 
	 */
	public class TestSuite
	{
        /**
         * @private
         */
		protected var caseCollection:ArrayCollection;
        /**
         * @private
         */
		protected var cursor:IViewCursor;

		/** 
		 * Gets the collection of test cases. Used for integration with FlexUnit4
		 * 
		 */
		public function getTests():ICollectionView {
			return caseCollection;
		}

		/** 
		 * Gets a count of all tests contained within all TestCases 
		 * managed by this TestSuite.
		 */
		public function getTestCount():int {
			var testCount:int = 0;

			for ( var i:int; i<caseCollection.length; i++ ) {
				testCount += caseCollection.getItemAt( i ).getTestCount();
			}
			
			return testCount;
		}

		/** 
		 * Calling this method gets the next TestCase or returns null if 
		 * there are no additional test cases.
		 * 
		 * @return The next test case in the suite.
		 */
		public function getNextTestCase():TestCase {
			var testCase:TestCase;
			if ( !cursor.afterLast && !cursor.beforeFirst ) {
				testCase = cursor.current as TestCase;
				cursor.moveNext();
				return testCase;
			} 

			return null;			
		}

		/** 
		 * Adds a TestCase to the suite.
		 * 
		 * @param testCase The testCase to be added to the suite.
		 */
		public function addTestCase( testCase:TestCase ):void {
			caseCollection.addItem( testCase );
			cursor.seek( CursorBookmark.FIRST );
		}

		/**
		 * @private
         */
		protected var _sorter:Sort;

		/** 
		 * Allows the developer to control the order that the test cases are run by specifying a 
		 * Sort to be used by the internal collection
		 */
		public function get sorter():Sort {
			return _sorter;
		}

		/**
		 * @private
         */
		public function set sorter( value:Sort ):void {
			if ( _sorter != value ) {
				_sorter = value;
				if ( caseCollection ) {
					caseCollection.sort = sorter;
					caseCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/**
		 * @private
         */
		protected var _filter:Function = defaultFilterFunction;

		/** 
		 * Allows the developer to control which test cases are executed by passing a filter function.
		 * 
		 * A function that the view will use to eliminate items that do not match the function's criteria. A 
		 * filterFunction is expected to have the following signature:
		 * 
		 * f(item:Object):Boolean
		 * 
		 * where the return value is true if the specified item should remain in the view. 
		 */
		public function get filter():Function {
			return _filter;
		}

		/**
		 * @private
         */
		public function set filter( value:Function ):void {
			if ( _filter != value ) {
				_filter = value;
				if ( caseCollection ) {
					caseCollection.filterFunction = filter;
					caseCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/** 
		 * A default implementation of the filterFunction which includes all test cases. The developer can provide their
		 * own filter function or override this through inheritance. 
		 */
		protected function defaultFilterFunction( item:Object ):Boolean {
			return true;
		}

        /**
         * Constructor.
         */
		public function TestSuite() {
			
			if (!sorter) {
				var sort:Sort = new Sort();
				sort.compareFunction = ClassSortUtils.testClassCompare;
				sorter = sort;
			}

			caseCollection = new ArrayCollection();
			caseCollection.sort = sorter;
			caseCollection.filterFunction = filter;
			caseCollection.refresh();
			
			cursor = caseCollection.createCursor();			
		}
	}
}