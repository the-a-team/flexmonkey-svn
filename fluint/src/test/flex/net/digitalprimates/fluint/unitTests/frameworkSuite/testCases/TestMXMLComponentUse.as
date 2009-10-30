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
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.ValidationResultEvent;
	
	import net.digitalprimates.fluint.sequence.SequenceCaller;
	import net.digitalprimates.fluint.sequence.SequenceEventDispatcher;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.sequence.SequenceSetter;
	import net.digitalprimates.fluint.sequence.SequenceWaiter;
	import net.digitalprimates.fluint.tests.TestCase;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.SimpleMXMLLoginComponent;

    /**
     * @private
     */
	public class TestMXMLComponentUse extends TestCase {
		protected static var LONG_TIME:int = 500;

		protected var loginForm:SimpleMXMLLoginComponent;
		override protected function setUp():void {
			super.setUp();
			
			loginForm = new SimpleMXMLLoginComponent();
			loginForm.addEventListener( FlexEvent.CREATION_COMPLETE, asyncHandler( pendUntilComplete, LONG_TIME ), false, 0, true );
			addChild( loginForm );
		}
		
		override protected function tearDown():void {
			super.tearDown();

			removeChild( loginForm );			
			loginForm = null;
		}

	    public function testLoginEventStandard() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.username = 'myuser1';
	    	passThroughData.password = 'somepsswd';
	    	
	    	//trace("Set at same time");
	    	loginForm.addEventListener( "loginRequested", asyncHandler( handleLoginEvent, LONG_TIME, passThroughData, handleLoginTimeout ), false, 0, true );
	    	loginForm.usernameTI.text = passThroughData.username;
	    	loginForm.passwordTI.text = passThroughData.password;
	    	loginForm.loginBtn.dispatchEvent( new MouseEvent( 'click', true, false ) );
	    }

	    public function testLoginEventSequence() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.username = 'myuser1';
	    	passThroughData.password = 'somepsswd';

	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( loginForm.usernameTI, {text:passThroughData.username} ) );
			sequence.addStep( new SequenceWaiter( loginForm.usernameTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceSetter( loginForm.passwordTI, {text:passThroughData.password} ) );
			sequence.addStep( new SequenceWaiter( loginForm.passwordTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceEventDispatcher( loginForm.loginBtn, new MouseEvent( MouseEvent.CLICK, true, false ) ) );
			sequence.addStep( new SequenceWaiter( loginForm, 'loginRequested', LONG_TIME ) );
			
			sequence.addAssertHandler( handleLoginEvent, passThroughData );
			
			sequence.run();
	    }

	    public function testValidationSequence() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.username = 'myuser1';
	    	passThroughData.password = 'somepsswd';

	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( loginForm.usernameTI, {text:passThroughData.username} ) );
			sequence.addStep( new SequenceWaiter( loginForm.usernameTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceSetter( loginForm.passwordTI, {text:passThroughData.password} ) );
			sequence.addStep( new SequenceWaiter( loginForm.passwordTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceEventDispatcher( loginForm.loginBtn, new MouseEvent( MouseEvent.CLICK, true, false ) ) );
			sequence.addStep( new SequenceWaiter( loginForm.sv1, ValidationResultEvent.VALID, LONG_TIME ) );
			
			sequence.addAssertHandler( handleValidEvent, passThroughData );
			
			sequence.run();
	    }

	    public function testInValidationSequence() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.username = 'myuser1';
	    	passThroughData.password = 'a';

	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( loginForm.usernameTI, {text:passThroughData.username} ) );
			sequence.addStep( new SequenceWaiter( loginForm.usernameTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceSetter( loginForm.passwordTI, {text:passThroughData.password} ) );
			sequence.addStep( new SequenceWaiter( loginForm.passwordTI, FlexEvent.VALUE_COMMIT, LONG_TIME ) );

			sequence.addStep( new SequenceEventDispatcher( loginForm.loginBtn, new MouseEvent( MouseEvent.CLICK, true, false ) ) );
			sequence.addStep( new SequenceWaiter( loginForm.sv2, ValidationResultEvent.INVALID, LONG_TIME ) );
			
			sequence.addAssertHandler( handleValidEvent, passThroughData );
			
			sequence.run();
	    }

	    public function testWithValidateNowSequence() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.username = 'myuser1';
	    	passThroughData.password = 'a';

	    	var sequence:SequenceRunner = new SequenceRunner( this );

			sequence.addStep( new SequenceSetter( loginForm.usernameTI, {text:passThroughData.username} ) );
			sequence.addStep( new SequenceCaller( loginForm.usernameTI, loginForm.validateNow ) );

			sequence.addStep( new SequenceSetter( loginForm.passwordTI, {text:passThroughData.password} ) );
			sequence.addStep( new SequenceCaller( loginForm.passwordTI, loginForm.validateNow ) );

			sequence.addStep( new SequenceCaller( loginForm, loginForm.setSomeValue, ['mike'] ) );
			sequence.addStep( new SequenceCaller( loginForm, loginForm.setSomeValue, null, getMyArgs ) );

			sequence.addStep( new SequenceEventDispatcher( loginForm.loginBtn, new MouseEvent( MouseEvent.CLICK, true, false ) ) );
			sequence.addStep( new SequenceWaiter( loginForm.sv2, ValidationResultEvent.INVALID, LONG_TIME ) );

			sequence.addAssertHandler( handleValidEvent, passThroughData );
			
			sequence.run();
	    }
	    
	    private function getMyArgs():Array {
	    	return ['steve'];
	    }

	    protected function handleLoginEvent( event:Event, passThroughData:Object ):void {
	    	//trace("Login Event Occurred " + event.type );
	    	assertEquals( passThroughData.username, event.target.username );
	    	assertEquals( passThroughData.password, event.target.password );
	    }

	    protected function handleValidEvent( event:Event, passThroughData:Object ):void {
	    	//trace("Valid Event Occurred " + event.type );
	    	assertEquals( passThroughData.username, loginForm.username );
	    	assertEquals( passThroughData.password, loginForm.password );
	    }

	    protected function handleLoginTimeout( passThroughData:Object ):void {
	    }
	}
}