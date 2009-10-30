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
package net.digitalprimates.fluint.utils {

	/** 
	 * Utility Classes for sorting objects in collections by their class name. 
	 */
	public class ClassSortUtils {
		import flash.utils.*;

		/** 
		 * Compares objects by checking their qualifiedNames against each other.
		 * 
		 * Needs caching to improve performance. 
		 * 
		 * @param a First item in sort comparison.
		 * @param b Second item in sort comparison.
		 * @param fields Array of SortFields.
		 */
		public static function testClassCompare( a:Object, b:Object, fields:Array=null ):int {
			var aName:String;
			var bName:String;
			
			aName = getQualifiedClassName( a );
			bName = getQualifiedClassName( b );

			return ClassSortUtils.compareNames( aName, bName );
		}

		/** 
		 * Function that can be passed directly to a collection sortFunction 
		 * to sort by className of the object instance.  
		 * 
		 * @param a First item in sort comparison.
		 * @param b Second item in sort comparison.
		 */
		public static function compareNames(a:Object, b:Object):int {
            if (a == null && b == null)
                return 0;

            if (a == null)
              return 1;

			if (b == null)
               return -1;

			if (a < b)
            	return -1;
            if (a > b)
            	return 1;
            return 0;
        }
	}
}