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
	import flash.events.Event;
	
	import net.digitalprimates.fluint.sequence.SequenceBindingWaiter;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.sequence.SequenceSetter;
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.valueObject.Person;

    /**
     * @private
     */
	public class TestBindingUse extends TestCase {
		protected static var LONG_TIME:int = 500;

		protected var person:Person;
		override protected function setUp():void {
			super.setUp();
			
			
			//Create a textInput, add it to the testEnvironment. Wait until it is created, then run tests on it
			person = new Person();
		}
		
		override protected function tearDown():void {
			super.tearDown();

			person = null;
		}

	    public function testSetPropertySuccess() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.firstName = 'mike';
	    	passThroughData.lastName = 'labriola';

			//set firstName, listen for firstName change
			//set lastName, listen for lastName change
	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( person, {firstName:passThroughData.firstName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'firstName', LONG_TIME ) );

			sequence.addStep( new SequenceSetter( person, {lastName:passThroughData.lastName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'lastName', LONG_TIME ) );
			
			sequence.addAssertHandler( handlePropertySetEvent, passThroughData );
			
			sequence.run();
	    }

/*
		This test case is valid, but I need to find a way to test it within the right context

	    public function testSetPropertyFail() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.firstName = 'mike';
	    	passThroughData.lastName = 'labriola';

			//This time we set the firstName property but wait for the lastName
	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( person, {firstName:passThroughData.firstName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'firstName', LONG_TIME ) );

			sequence.addStep( new SequenceSetter( person, {firstName:passThroughData.lastName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'lastName', LONG_TIME ) );

			sequence.addAssertHandler( handleShouldNotGetHere, passThroughData );
			
			try {
				sequence.run();
			}
			
			catch (e:Error) {
				trace("Caught error");
			}
	    }
*/
	    public function testLastNameTimeOut() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.firstName = 'mike';
	    	passThroughData.lastName = 'labriola';

			//This time we set the firstName property but wait for the lastName
	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( person, {firstName:passThroughData.firstName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'firstName', LONG_TIME ) );

			//sequence.addStep( new SequenceSetter( person, {firstName:passThroughData.lastName} ) );
			sequence.addStep( new SequenceBindingWaiter( person, 'lastName', LONG_TIME, handlePropertyShouldFailTimeOut ) );

			sequence.addAssertHandler( handleShouldNotGetHere, passThroughData );
			
			sequence.run();
	    }

	    protected function handlePropertySetEvent( event:Event, passThroughData:Object ):void {
	    	//trace("Property Changed Event Occurred " + event.type );
	    	assertEquals( passThroughData.firstName, event.target.firstName );
	    }

	    protected function handleShouldNotGetHere( event:Event, passThroughData:Object ):void {
	    	fail( "Test should have timed out");
	    }
	    
	    protected function handlePropertyShouldFailTimeOut( passThroughData:Object ):void {
	    	//Property timed out correctly
	    }
	}
}