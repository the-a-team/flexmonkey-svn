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
package net.digitalprimates.fluint.tests {
    /**
     * Used to keep a string representation of the method name
     * along with a reference to the actual method. Used in 
     * TestMonitor and TestCase.
     */
	public class TestMethod {
        /**
         * Reference to a method in a test case that will be executed.
         */
		public var method:Function;

        /**
         * String representation of the method name.
         */
		public var methodName:String;

        /**
         * XML metadata information accompanying method.
         */
		public var metadata:XML;
		
        /**
         * Constructor.
         * 
         * Called to create a TestMethod object.  It keeps a string representation 
         * of the method name along with a reference to the actual method. 
         * 
         * Used in TestMonitor and TestCase.
         * 
         * @param method Reference to the test method.
         * @param methodName Name of the test method.
         * @param metadata Metadata defined for the test method using the [Test] metadata. (optional)
         */
		public function TestMethod( method:Function, methodName:String, metadata:XML=null ) {
			this.method = method;
			this.methodName = methodName;
			this.metadata = metadata;
		}
	}
}