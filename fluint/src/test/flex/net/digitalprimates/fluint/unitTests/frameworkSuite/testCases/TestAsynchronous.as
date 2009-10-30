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
package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.digitalprimates.fluint.assertion.AssertionFailedError;
	import net.digitalprimates.fluint.tests.TestCase;

    /**
     * @private
     */
	public class TestAsynchronous extends TestCase {
		protected var timer:Timer;
		protected static var SHORT_TIME:int = 100;
		protected static var LONG_TIME:int = 250;

		override protected function setUp():void {
			super.setUp();

			timer = new Timer( LONG_TIME, 1 );
		}
		
		override protected function tearDown():void {
			super.tearDown();

			if ( timer ) {
				timer.stop();
			}
			
			timer = null;
		}

	    public function testInTimePass() : void {
	    	//We fire in SHORT_TIME mills, but are willing to wait LONG_TIME
	    	timer.delay = SHORT_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldPass, LONG_TIME, null, handleAsyncShouldNotFail ), false, 0, true ); 
	    	timer.start();
	    }

	    public function testInTimeFail() : void {
	    	//We fire in SHORT_TIME mills, but are willing to wait LONG_TIME
	    	timer.delay = SHORT_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldPassCallFail, LONG_TIME, null, handleAsyncShouldNotFail ), false, 0, true ); 
	    	timer.start();
	    }

	    public function testInTimeError() : void {
	    	//We fire in SHORT_TIME mills, but are willing to wait LONG_TIME
	    	timer.delay = SHORT_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldPassCauseError, LONG_TIME, null, handleAsyncShouldNotFail ), false, 0, true ); 
	    	timer.start();
	    }
	    
	    public function testTooLatePass() : void {
	    	//We fire in LONG_TIME mills, but are willing to wait SHORT_TIME
	    	timer.delay = LONG_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldNotPass, SHORT_TIME, null, handleAsyncShouldFail ), false, 0, true ); 
	    	timer.start();
	    }

	    public function testTooLateFail() : void {
	    	//We fire in LONG_TIME mills, but are willing to wait SHORT_TIME
	    	timer.delay = LONG_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldNotPass, SHORT_TIME, null, handleAsyncShouldFailCallFail ), false, 0, true ); 
	    	timer.start();
	    }

	    public function testTooLateError() : void {
	    	//We fire in LONG_TIME mills, but are willing to wait SHORT_TIME
	    	timer.delay = LONG_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleAsyncShouldNotPass, SHORT_TIME, null, handleAsyncShouldFailCauseError ), false, 0, true ); 
	    	timer.start();
	    }
	    
	    public function testNotReallyAsynchronousPass() : void {
	    	//This tests one of the edges that flex unit did not handle well. What if we receive our async event *before*
	    	//this method finishes executing
	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( handleAsyncShouldPassImmediate, SHORT_TIME, null, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    }

	    public function testNotReallyAsynchronousFail() : void {
	    	//This tests one of the edges that flex unit did not handle well. What if we receive our async event *before*
	    	//this method finishes executing
	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( handleAsyncShouldPassImmediateCallFail, SHORT_TIME, null, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    }

	    public function testNotReallyAsynchronousFailAfterAsync() : void {
	    	//This tests one of the edges that flex unit did not handle well. What if we receive our async event *before*
	    	//this method finishes executing, but then something else in the method execution causes a failure
	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( handleAsyncShouldPassImmediate, SHORT_TIME, null, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    	
	    	//A failure now should still know to mark this method as failed, despite the async completing, verify this
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
		    	if ( registeredMethod != testNotReallyAsynchronousFailAfterAsync ) {
			    	fail( 'Proceeded to next test method after async before completing method body' );
		    	}
	            return;
	        }
	        throw new AssertionFailedError("Async Fail Uncaught");
	    }
	    	

	    public function testMethodBodyExecuting() : void {
	    	//This is a simple flag which makes a lot of difference. If the methodBodyExecuting flag is set to true, we are still in
	    	//the method body of the test execution and should not consider a test complete. It is important for cases where
	    	//the async may fire before the method body execution if complete
	    	
	    	if ( !methodBodyExecuting ) {
		    	fail( 'Method body is executing, but methodBodyExecuting is false' );
	    	}
	    }

	    public function testMethodBodyExecutingPending() : void {
	    	//Ensure the method body executing flag is true if the async event happens before the method body execution is complete
	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( checkMethodBodyExecutingFlagTrue, SHORT_TIME, null, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    }

	    public function testMethodBodyExecutingComplete() : void {
	    	//Ensure the method body executing flag is false if the async event happens after the method body execution is complete
	    	timer.delay = SHORT_TIME;
	    	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( checkMethodBodyExecutingFlagFalse, LONG_TIME, null, handleAsyncShouldNotFail ), false, 0, true ); 
	    	timer.start();
	    }

	    public function testPassThroughDataOnSuccess() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.randomValue = 5;
	    	passThroughData.timer = timer;

	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( checkPassThroughDataOnSuccess, SHORT_TIME, passThroughData, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    }

	    public function testPassThroughDataOnFailure() : void {
	    	var passThroughData:Object = new Object();
	    	passThroughData.randomValue = 5;
	    	passThroughData.timer = timer;

	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( handleAsyncShouldNotPass, SHORT_TIME, passThroughData, checkPassThroughDataOnTimeout ), false, 0, true );

			//Never dispatch the event. Allow the timeout to occur
			//eventDispatcher.dispatchEvent( new Event('immediate') ); 
	    }

	    public function testEventDataCorrect() : void {
	    	var eventDispatcher:EventDispatcher = new EventDispatcher();
	    	eventDispatcher.addEventListener('immediate', asyncHandler( checkEventData, SHORT_TIME, null, handleAsyncShouldNotFail ), false, 0, true );
	    	eventDispatcher.dispatchEvent( new DataEvent('immediate', false, false, '0123456789' ) ); 
	    }

	    public function NotestMultipleAsyncAllSucceed() : void {
	    	//Run both of these two previous async tests at the same time. FlexUnit had major issues with reentrance and single AsyncHelpers
			testInTimePass();
			testNotReallyAsynchronousPass();
	    }

	    public function NOtestMultipleAsyncSuccessAndTimeout() : void {
	    	testTooLateFail();
			testNotReallyAsynchronousPass();
	    }

	    public function testMultipleAsyncFirstReturnsBeforeSecondSuccess() : void {
			testNotReallyAsynchronousPass();
			testInTimePass();
	    }

	    public function testMultipleAsyncFirstReturnsBeforeSecondTimeout() : void {
			testNotReallyAsynchronousPass();
			testTooLateFail();
	    }

		/** Helper methods for the tests above beyond this point
		 * 
		 * 
		 * 
		 * **/
		protected function checkEventData( event:DataEvent, passThroughData:Object ):void {
			assertEquals( event.data, '0123456789' );  
		}

		protected function checkPassThroughDataOnSuccess( event:Event, passThroughData:Object ):void {
			assertEquals( passThroughData.randomValue, 5 );
			assertStrictlyEquals( passThroughData.timer, timer );
		}

		protected function checkPassThroughDataOnTimeout( passThroughData:Object ):void {
			assertEquals( passThroughData.randomValue, 5 );
			assertStrictlyEquals( passThroughData.timer, timer );
		}

		protected function checkMethodBodyExecutingFlagTrue( event:Event, passThroughData:Object ):void {
	    	if ( !methodBodyExecuting ) {
		    	fail( 'Method body is executing, but methodBodyExecuting is false' );
	    	}
		}

		protected function checkMethodBodyExecutingFlagFalse( event:Event, passThroughData:Object ):void {
	    	if ( methodBodyExecuting ) {
		    	fail( 'Method body is not executing, but methodBodyExecuting is true' );
	    	}
		}

	    protected function handleAsyncShouldPassImmediate( event:Event, passThroughData:Object ):void {
	    }

	    protected function handleAsyncShouldPassImmediateCallFail( event:Event, passThroughData:Object ):void {
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("Async Fail Uncaught");
	    }

	    protected function handleAsyncShouldPass( event:Event, passThroughData:Object ):void {
	    }

	    protected function handleAsyncShouldNotPass( event:Event, passThroughData:Object ):void {
	    	fail('Timer event received after Timeout Occured');
	    }

	    protected function handleAsyncShouldPassCallFail( event:Event, passThroughData:Object ):void {
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("Async Fail Uncaught");
	    }

	    protected function handleAsyncShouldPassCauseError( event:Event, passThroughData:Object ):void {
	        try 
	        {
	        	//do not instantiate
	        	var blah:Date;
	        	//Cause an error
	        	blah.date = blah.day + 5;
	        } 
	        catch ( e : Error ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("Error Uncaught");
	    }

		//----------------------------------

	    protected function handleAsyncShouldFail( passThroughData:Object ):void {
	    }

	    protected function handleAsyncShouldNotFail( passThroughData:Object ):void {
	    	fail('Timeout Reached Incorrectly');
	    }

	    protected function handleAsyncShouldFailCallFail( passThroughData:Object ):void {
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("Async Fail Uncaught");
	    }

	    protected function handleAsyncShouldFailCauseError( passThroughData:Object ):void {
	        try 
	        {
	        	//do not instantiate
	        	var blah:Date;
	        	//Cause an error
	        	blah.date = blah.day + 5;
	        } 
	        catch ( e : Error ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("Error Uncaught");
	    }

	}

}