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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.events.PropertyChangeEvent;
	import mx.rpc.IResponder;
	import mx.utils.*;
	
	import net.digitalprimates.fluint.assertion.AssertionFailedError;
	import net.digitalprimates.fluint.async.AsyncHandler;
	import net.digitalprimates.fluint.async.AsyncTestResponder;
	import net.digitalprimates.fluint.async.ITestResponder;
	import net.digitalprimates.fluint.events.AsyncEvent;
	import net.digitalprimates.fluint.events.AsyncResponseEvent;
	import net.digitalprimates.fluint.monitor.TestCaseResult;
	import net.digitalprimates.fluint.monitor.TestMethodResult;
	import net.digitalprimates.fluint.monitor.TestMonitor;
	import net.digitalprimates.fluint.sequence.SequenceBindingWaiter;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.ui.TestEnvironment;

	/** 
	 * <p>
	 * The TestCase is the class extended to create your own test cases. </p>
	 * 
	 * <p>
	 * A test case is an object with a variety of method beginning with 
	 * the lower case letters 'test'. The TestCase class ensures that 
	 * tests are always run in the following order:</p>
	 * 
	 * <p><code>
	 * run setup()<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p><code>
	 * run the test method<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p><code>
	 * run tearDown()<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p>
	 * The loop then begins again for the next test method.</p>
	 */
	public class TestCase extends EventDispatcher {

        /**
         * @private
         */
        protected var _testMonitor:TestMonitor;

        public function get testMonitor():TestMonitor {
        	return _testMonitor;
        }
        
        public function set testMonitor( value:TestMonitor ):void {
        	_testMonitor = value; 
        }
		
        /**
         * @private
         */
		public static var TEST_COMPLETE:String = "testComplete";

        /**
         * @private
         */
		private var testCollection:XMLListCollection;

		/** 
		 * Gets the collection of test cases. Used for integration with FlexUnit4
		 * 
		 */
		public function getTests():ICollectionView {
			return testCollection;
		}
		
        /**
         * @private
         */
		private var cursor:IViewCursor;

        /**
         * @private
         */
		protected var pendingAsyncCalls:Array = new Array();

        /**
         * @private
         */
		protected var methodBodyExecuting:Boolean = false;

        /**
         * @private
         */
		protected var setupTearDownFailed:Boolean = false;

        /**
         * @private
         */
		protected var registeredMethod:Function;

        /**
         * @private
         */
		protected var tickCountOnStart:Number;

        /**
         * @private
         */
		public function runSetup():void {
			methodBodyExecuting = true;
			executeMethodWhileProtected( setUp ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}

        /**
         * @private
         */
		public function runTestMethod( method:Function ):void {
			tickCountOnStart = getTimer();

			methodBodyExecuting = true;
			executeMethodWhileProtected( method ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult && ( !methodResult.traceInformation ) ) {
					methodResult.executed = true;
					methodResult.testDuration = getTimer()-tickCountOnStart;
					methodResult.traceInformation = "Test completed in " + methodResult.testDuration + "ms";
				}

				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}


        /**
         * @private
         */
		public function runTearDown():void {
			removeAllAsyncEventListeners();

			methodBodyExecuting = true;
			executeMethodWhileProtected( tearDown ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}

        /**
         * @private
         */
		private function startAsyncTimers():void {
			for ( var i:int=0; i<pendingAsyncCalls.length; i++ ) {
				( pendingAsyncCalls[ i ] as AsyncHandler ).startTimer();
			}
		}

        /**
         * @private
         */
		private function removeAsyncEventListeners( asyncHandler:AsyncHandler ):void {
			asyncHandler.removeEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false );
			asyncHandler.removeEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false );
		}

        /**
         * @private
         */
		private function removeAllAsyncEventListeners():void {
			for ( var i:int=0; i<pendingAsyncCalls.length; i++ ) {
				removeAsyncEventListeners( pendingAsyncCalls[ i ] as AsyncHandler );
			}
		}

        /**
         * @private
         */
		public function get hasPendingAsync():Boolean {
			return ( pendingAsyncCalls.length > 0 );
		}

        /**
         * @private
         */
		private function handleAsyncEventFired( event:AsyncEvent ):void {
			//Receiving this event is a good things... IF it is the first one we are waiting for
			//If it is not the first one on the stack though, we still need to fail.
			var asyncHandler:AsyncHandler = event.target as AsyncHandler;
			var firstPendingAsync:AsyncHandler;
			
			removeAsyncEventListeners( asyncHandler );
			
			if ( hasPendingAsync ) {
				firstPendingAsync = pendingAsyncCalls.shift() as AsyncHandler;
				
				if ( firstPendingAsync === asyncHandler ) {
					if ( asyncHandler.eventHandler != null  ) {
						//this actually needs to be the event object from the previous event
						protect( asyncHandler.eventHandler, event.originalEvent, firstPendingAsync.passThroughData );  
					}
				} else {
					//The first one on the stack is not the one we received. 
					//We received this one out of order, which is a failure condition
					protect( fail, "Asynchronous Event Received out of Order" ); 
				}
			} else {
				//We received an event, but we were not waiting for one, failure
				protect( fail, "Unexpected Asynchronous Event Occurred" ); 
			}
			
			if ( !hasPendingAsync && !methodBodyExecuting ) {
				//We have no more pending async, *AND* the method body of the function that originated this message
				//has also finished, then let the test runner know
				var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult && ( !methodResult.traceInformation )  ) {
					methodResult.executed = true;
					methodResult.testDuration = getTimer()-tickCountOnStart;
					methodResult.traceInformation = "Test completed via Async Event in " + methodResult.testDuration + "ms";
				}

				dispatchEvent( new Event( TEST_COMPLETE ) );				
			}
			
		}

        /**
         * @private
         */
		private function handleAsyncTimeOut( event:Event ):void {
			var asyncHandler:AsyncHandler = event.target as AsyncHandler; 
			
			removeAsyncEventListeners( asyncHandler );

			if ( asyncHandler.timeoutHandler != null ) {
				protect( asyncHandler.timeoutHandler, asyncHandler.passThroughData ); 
			} else {
				protect( fail, "Timeout Occurred before expected event" );
			}

			//Remove all future pending items
			removeAllAsyncEventListeners();
			pendingAsyncCalls = new Array();

			var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
			if ( methodResult && ( !methodResult.traceInformation ) ) {
				methodResult.executed = true;
				methodResult.testDuration = getTimer()-tickCountOnStart;
				methodResult.traceInformation = "Test completed via Async TimeOut in " + methodResult.testDuration + "ms";
			}

			//Our timeout has failed, declare this specific test complete and move along
			dispatchEvent( new Event( TEST_COMPLETE ) );
		}

        /**
         * @private
         */
		private function protect( method:Function, ... rest ):void {
			var methodResult:TestMethodResult;
			var setupTearDownFailure:Boolean = false;

			methodResult = testMonitor.getTestMethodResult( registeredMethod );

			if ( !setupTearDownFailed ) {
				try {
					if ( rest && rest.length>0 ) {
						method.apply( this, rest );
					} else {
						method();
					}
				}
			
				catch ( e:Error ) {
					if ( ( registeredMethod == setUp ) || 
					     ( registeredMethod == tearDown ) ) {
						    setupTearDownFailed = true;
							var testCaseResult:TestCaseResult = testMonitor.getTestCaseResult( this );
							testCaseResult.status = false;
	
							//This is needed to ensure the testCase is update with information regarding a failure
							//in the setup or teardown as that is really more of a case issue then a method issue
							if ( !testCaseResult.traceInformation ) {
								testCaseResult.traceInformation = e.getStackTrace();
							} else {
								testCaseResult.traceInformation += ( '\n' + e.getStackTrace() );
							}
						} else {
							methodResult = testMonitor.getTestMethodResult( registeredMethod );
/*
							if ( !methodResult.traceInformation ) {
								methodResult.traceInformation = e.getStackTrace();
							} else {
								methodResult.traceInformation += ( '\n' + e.getStackTrace() );
							}
*/							
							methodResult.error = e;
							methodResult.executed = true;
							methodResult.testDuration = getTimer()-tickCountOnStart;
					}
				}

			} else {
				//If setup or teardown failed, we need to assume the remainder of the methods in this testcase are invalid
				methodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult ) {
					methodResult.executed = true;
					methodResult.error = new Error("Setup/Teardown Error");
					methodResult.traceInformation = "Setup or Teardown Failed for this TestCase. Method is invalid. Review Testcase for stackTrace information";
					methodResult.testDuration = getTimer()-tickCountOnStart;
				}
			}

		}

        /**
         * @private
         */
		private function executeMethodWhileProtected( method:Function, ... rest ):void {
			
			var p:Function = protect;

			registeredMethod = method;
			(rest as Array).push( method );
			p.apply( this, rest );
		} 

        /**
         * @private
         */
	    public function handleBindableNextSequence( event:PropertyChangeEvent, sequenceRunner:SequenceRunner ):void {
	    	if ( sequenceRunner.getPendingStep() is SequenceBindingWaiter ) {

				var sequenceBinding:SequenceBindingWaiter = sequenceRunner.getPendingStep() as SequenceBindingWaiter;

				if ( event && event.target && event.property == sequenceBinding.propertyName ) {
					//Remove the listener for this particular item
			    	event.currentTarget.removeEventListener(event.type, handleBindableNextSequence );
	
					sequenceRunner.continueSequence( event );
					
					startAsyncTimers();
				} else {
					protect( fail, "Incorrect Property Change Event Received" );
				}
	    	} else {
				protect( fail, "Event Received out of Order" ); 
	    	}
	    }

        /**
         * @private
         */
	    public function handleNextSequence( event:Event, sequenceRunner:SequenceRunner ):void {
			if ( event && event.target ) {
				//Remove the listener for this particular item
		    	event.currentTarget.removeEventListener(event.type, handleNextSequence );
			}

			sequenceRunner.continueSequence( event );
			
			startAsyncTimers();
	    }

        /**
         * @private
         */
		private function getMetaDataFromNode( node:XML ):XML {
			var metadata:XML;

			if ( node.hasOwnProperty( 'metadata' ) ) {
				var xmlList:XMLList = node.metadata.(@name="Test"); 
				metadata = xmlList?xmlList[0]:null; 
			}			

			return metadata;
		}

        /**
         * @private
         */
		private function getMethodNameFromNode( node:XML ):String {
			return ( node.@name );
		}

        /**
         * @private
         */
		private function getMethodFromNode( node:XML ):Function {
			return ( this[ node.@name ] as Function );
		}

        /**
         * @private
         */
		public function getTestCount():int {
			return testCollection.length;
		}

        /**
         * @private
         */
		public function getNextTestMethod():TestMethod {
			var methodNode:XML;
			if ( !cursor.afterLast && !cursor.beforeFirst ) {
				methodNode = cursor.current as XML;
				cursor.moveNext();

				return new TestMethod( getMethodFromNode( methodNode ), getMethodNameFromNode( methodNode ), getMetaDataFromNode( methodNode ) );
			} 

			return null;			
		}
		
        /**
         * @private
         */
		private function buildTestCollection():XMLListCollection {
			var testMethods:XMLListCollection;
			var record:DescribeTypeCacheRecord = DescribeTypeCache.describeType( this );
			var typeDetail:XML = record.typeDescription;
			//var methods:XMLList = typeDetail.method.( /^test.*/.test( @name ) );
			//We now use a filterFunction to grab only test* methods as opposed to here
			var methods:XMLList = typeDetail.method;
			testMethods = new XMLListCollection( methods );
			
			return testMethods;
		}
		
		/** 
		 * Provides a reference to the TestEnvironment. 
		 * 
		 * A singleton container that exists to allow visual children to be
		 * created and tested. 
		 */
        protected var _testEnvironment:TestEnvironment;

        public function get testEnvironment():TestEnvironment {
        	return _testEnvironment;
        }
        
        public function set testEnvironment( value:TestEnvironment ):void {
        	_testEnvironment = value; 
        }
		
	    /**
	     *  Adds a child DisplayObject to the TestEnvironment.
	     *  The child is added after other existing children,
	     *  so that the first child added has index 0,
	     *  the next has index 1, an so on.
	     *
	     *  <p><b>Note: </b>While the <code>child</code> argument to the method
	     *  is specified as of type DisplayObject, the argument must implement
	     *  the IUIComponent interface to be added as a child of a container.
	     *  All Flex components implement this interface.</p>
	     *
	     *  @param child The DisplayObject to add as a child of the TestEnvironment.
	     *  It must implement the IUIComponent interface.
	     *
	     *  @return The added child as an object of type DisplayObject. 
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of the added component.
	     *
	     *  @see mx.core.Container
	     *
	     *  @tiptext Adds a child object to this container.
	     */
		public function addChild(child:DisplayObject):DisplayObject {
			return testEnvironment.addChild( child );
		}

	    /**
	     *  Adds a child DisplayObject to the TestEnvironment.
	     *  The child is added at the index specified.
	     *
	     *  <p><b>Note: </b>While the <code>child</code> argument to the method
	     *  is specified as of type DisplayObject, the argument must implement
	     *  the IUIComponent interface to be added as a child of TestEnvironment.
	     *  All Flex components implement this interface.</p>
	     *
	     *  @param child The DisplayObject to add as a child of the TestEnvironment.
	     *  It must implement the IUIComponent interface.
	     *
	     *  @param index The index to add the child at.
	     *
	     *  @return The added child as an object of type DisplayObject. 
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of the added component.
	     *
	     *  @see mx.core.Container
	     */
		public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			return testEnvironment.addChildAt( child, index );
		}  

	    /**
	     *  Removes a child DisplayObject from the child list of the TestEnviroment.
	     *  The removed child will have its <code>parent</code>
	     *  property set to null. 
	     *  The child will still exist unless explicitly destroyed.
	     *  If you add it to another container,
	     *  it will retain its last known state.
	     *
	     *  @param child The DisplayObject to remove.
	     *
	     *  @return The removed child as an object of type DisplayObject. 
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of the removed component.
	     */
		public function removeChild(child:DisplayObject):DisplayObject {
			return testEnvironment.removeChild( child );
		} 

	    /**
	     *  Removes a child DisplayObject from the child list of the TestEnvironment
	     *  at the specified index.
	     *  The removed child will have its <code>parent</code>
	     *  property set to null. 
	     *  The child will still exist unless explicitly destroyed.
	     *  If you add it to another container,
	     *  it will retain its last known state.
	     *
	     *  @param index The child index of the DisplayObject to remove.
	     *
	     *  @return The removed child as an object of type DisplayObject. 
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of the removed component.
	     */
		public function removeChildAt(index:int):DisplayObject {
			return testEnvironment.removeChildAt( index );
		} 

	    /**
	     *  Removes all children from the child list of this container.
	     */
		public function removeAllChildren():void {
			return testEnvironment.removeAllChildren();
		} 

	    /**
	     *  Gets the <i>n</i>th child component object.
	     *
	     *  <p>The children returned from this method include children that are
	     *  declared in MXML and children that are added using the
	     *  <code>addChild()</code> or <code>addChildAt()</code> method.</p>
	     *
	     *  @param childIndex Number from 0 to (numChildren - 1).
	     *
	     *  @return Reference to the child as an object of type DisplayObject. 
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of a specific Flex control, such as ComboBox or TextArea.
	     */
	    public function getChildAt(index:int):DisplayObject {
	    	return testEnvironment.getChildAt( index );
	    }

	    /**
	     *  Returns the child whose <code>name</code> property is the specified String.
	     *
	     *  @param name The identifier of the child.
	     *
	     *  @return The DisplayObject representing the child as an object of type DisplayObject.
	     *  You typically cast the return value to UIComponent, 
	     *  or to the type of a specific Flex control, such as ComboBox or TextArea.
	     */
	    public function getChildByName(name:String):DisplayObject {
	    	return testEnvironment.getChildByName( name );
	    }

	    /**
	     *  Gets the zero-based index of a specific child.
	     *
	     *  <p>The first child of the Test Environment (i.e.: the first child tag
	     *  that appears in the MXML declaration) has an index of 0,
	     *  the second child has an index of 1, and so on.
	     *  The indexes of the test environemnt children determine
	     *  the order in which they get laid out.
	     *  For example, in a VBox the child with index 0 is at the top,
	     *  the child with index 1 is below it, etc.</p>
	     *
	     *  <p>If you add a child by calling the <code>addChild()</code> method,
	     *  the new child's index is equal to the largest index among existing
	     *  children plus one.
	     *  You can insert a child at a specified index by using the
	     *  <code>addChildAt()</code> method; in that case the indices of the
	     *  child previously at that index, and the children at higher indices,
	     *  all have their index increased by 1 so that all indices fall in the
	     *  range from 0 to <code>(numChildren - 1)</code>.</p>
	     *
	     *  <p>If you remove a child by calling <code>removeChild()</code>
	     *  or <code>removeChildAt()</code> method, then the indices of the
	     *  remaining children are adjusted so that all indices fall in the
	     *  range from 0 to <code>(numChildren - 1)</code>.</p>
	     *
	     *  <p>If <code>myView.getChildIndex(myChild)</code> returns 5,
	     *  then <code>myView.getChildAt(5)</code> returns myChild.</p>
	     *
	     *  <p>The index of a child may be changed by calling the
	     *  <code>setChildIndex()</code> method.</p>
	     *
	     *  @param child Reference to child whose index to get.
	     *
	     *  @return Number between 0 and (numChildren - 1).
	     */
	    public function getChildIndex(child:DisplayObject):int {
	    	return testEnvironment.getChildIndex( child );
	    }

	    /**
	     *  Sets the index of a particular child.
	     *  See the <code>getChildIndex()</code> method for a
	     *  description of the child's index.
	     *
	     *  @param child Reference to child whose index to set.
	     *
	     *  @param newIndex Number that indicates the new index.
	     *  Must be an integer between 0 and (numChildren - 1).
	     */
		public function setChildIndex(child:DisplayObject, newIndex:int):void {
			testEnvironment.setChildIndex( child, newIndex );
		} 

	    /**
	     *  Number of child components in the TestEnvironment.
	     *
	     *  <p>The number of children is initially equal
	     *  to the number of children declared in MXML.
	     *  At runtime, new children may be added by calling
	     *  <code>addChild()</code> or <code>addChildAt()</code>,
	     *  and existing children may be removed by calling
	     *  <code>removeChild()</code>, <code>removeChildAt()</code>,
	     *  or <code>removeAllChildren()</code>.</p>
	     */
		public function get numChildren():int {
			return testEnvironment.numChildren;
		}

		/**
		 * The setup method can be overriden to create test case specific 
		 * conditions in which each of the test methods run.
		 * 
		 * For each test in a TestCase, the following procedure is followed:
		 * 
		 * run setup()
		 * 		wait for any outstanding asynchronous events
		 * run the test method
		 * 		wait for any outstanding asynchronous events
		 * run tearDown()
		 * 		wait for any outstanding asynchronous events
		 * 
		 * The loop then begins again for the next test method.
		 */
		protected function setUp():void {
		}

		/** 
		 * Teardown is used to destroy any items created during setup to rest the test environment
		 * for the next test.
		 * 
		 * For example, if a Timer is created during the setUp() method, the reference to that
		 * Timer must be set as null in the teardown to ensure it is recreated the next time
		 * setUp() is run.
		 * 
		 * The teardown method needs to be overriden whenever the setup method is overriden.
		 **/ 		
		protected function tearDown():void {
		}

		/**
		 * <p>
		 * The asyncHandler method is used to create a new AsyncHandler instance, 
		 * which is a helper object that monitors an object for an event to occur, 
		 * and allows the test case to resume on its success, or handle the timeout 
		 * condition, where the specified event does not occur within a provided timeout.</p>
		 * 
		 * <p>
		 * The method can be used in the following ways:</p>
		 * 
		 * <p><code>
		 * var handler:Function = asyncHandler( handleSomeEvent, 250, null, handleTimeOut );
		 * someObject.addEventListener( 'someEvent', handler, false, 0, true );
		 * </code></p>
		 * OR
		 * <p>
		 * combined into a single statment:<br/>
		 * <code>
		 * someObject.addEventListener( 'someEvent', asyncHandler( handleSomeEvent, 250, null, handleTimeOut ), false, 0, true );</code></p>
		 * 
		 * <p>
		 * The former allows the developer to keep a handler to the created method and therefore
		 * manually garbage collect it in the future. If you choose not to keep a reference to
		 * the created object, you will need to set the weaklistener object to true in the 
		 * addEventListener method or your handlers and potentially setup objects may 
		 * not be garbage collected.</p>
		 * 
		 * @param eventHandler
		 *  A reference to the event handler that should be called if the event named in the TestCase.asyncHandler() 
		 *  method fires before the timeout is reached. The handler is expected to have the follow signature:
		 *  <p><code>
		 *  public function handleEvent( event:Event, passThroughData:Object ):void {
		 *  }</code></p>
		 * 
		 * <p>
		 * The first parameter is the original event object.
		 * The second parameter is a generic object that can optionally be provided by the developer when starting
		 * a new asynchronous operation.
		 * 
		 * @param timeout
		 *  The number of milliseconds to wait for the event declared in the addEventListener method to occur before
		 *  determining that this mehtod has timed-out.
		 * 
		 * @param passThroughData
		 * 	A generic object that is optionally provided by the developer when starting a new asynchronous operation.
		 *  This generic object is passed to the eventHandler function if it is called.
		 * 
		 * @param timeoutHandler
		 * 	A reference to the event handler that should be called if the event named in the addEventListener 
		 *  method does not fire before the timeout is reached. The handler is expected to have the follow signature:
		 *  <p><code>
		 *  public function handleTimeoutEvent( passThroughData:Object ):void {
		 *  }</code></p>
		 *  <p>
		 *  The parameter is a generic object that will receive any data provided to the passThroughData parameter of this method.</p>
		 */
		public function asyncHandler( eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function { 
			var asyncHandler:AsyncHandler = new AsyncHandler( this, eventHandler, timeout, passThroughData, timeoutHandler )
			asyncHandler.addEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false, 0, true );
			asyncHandler.addEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false, 0, true );

			pendingAsyncCalls.push( asyncHandler );

			return asyncHandler.handleEvent;
		}

		public function asyncResponder( responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder { 

			if ( !( ( responder is IResponder ) || ( responder is ITestResponder ) ) ) {
				throw new Error( "Object provided to responder parameter of asyncResponder is not a IResponder or ITestResponder" );
			}

			var asyncResponder:AsyncTestResponder = new AsyncTestResponder( responder );

			var asyncHandler:AsyncHandler = new AsyncHandler( this, handleAsyncTestResponderEvent, timeout, passThroughData, timeoutHandler )
			asyncHandler.addEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false, 0, true );
			asyncHandler.addEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false, 0, true );

			pendingAsyncCalls.push( asyncHandler );

			asyncResponder.addEventListener( AsyncResponseEvent.RESPONDER_FIRED, asyncHandler.handleEvent, false, 0, true ); 

			return asyncResponder;
		}

		protected function handleAsyncTestResponderEvent( event:AsyncResponseEvent, passThroughData:Object=null ):void {
			var originalResponder:* = event.originalResponder;
			var isTestResponder:Boolean = false;
			
			if ( originalResponder is ITestResponder ) {
				isTestResponder = true;
			}
			
			if ( event.status == 'result' ) {
				if ( isTestResponder ) {
					originalResponder.result( event.data, passThroughData );
				} else {
					originalResponder.result( event.data );					
				}
			} else {
				if ( isTestResponder ) {
					originalResponder.fault( event.data, passThroughData );
				} else {
					originalResponder.fault( event.data );					
				}
			}
		}
//------------------------------------------------------------------------------

		/**
		 * Asserts that the two provided values are equal
		 */
		protected function assertEquals(... rest):void
		{
			if ( rest.length == 3 )
				failNotEquals( rest[0], rest[1], rest[2] );
			else
				failNotEquals( "", rest[0], rest[1] );
		}
	
        /**
         * @private
         */
		protected function failNotEquals( message:String, expected:Object, actual:Object ):void
		{
			if ( expected != actual )
			   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
		}
	
		/**
		 * Asserts that the provided values are strictly equal.
		 */
		protected function assertStrictlyEquals(... rest):void
		{
			if ( rest.length == 3 )
				failNotStrictlyEquals( rest[0], rest[1], rest[2] );
			else
				failNotStrictlyEquals( "", rest[0], rest[1] );
		}
	
        /**
         * @private
         */
		protected function failNotStrictlyEquals( message:String, expected:Object, actual:Object ):void
		{
			if ( expected !== actual )
			   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to true.
		 */
		protected function assertTrue(... rest):void
		{
			if ( rest.length == 2 )
				failNotTrue( rest[0], rest[1] );
			else
				failNotTrue( "", rest[0] );
		}
	
        /**
         * @private
         */
		protected function failNotTrue( message:String, condition:Boolean ):void
		{
			if ( !condition )
			   failWithUserMessage( message, "expected true but was false" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to false.
		 */
		protected function assertFalse(... rest):void
		{
			if ( rest.length == 2 )
				failTrue( rest[0], rest[1] );
			else
				failTrue( "", rest[0] );
		}
	
        /**
         * @private
         */
		protected function failTrue( message:String, condition:Boolean ):void
		{
			if ( condition )
			   failWithUserMessage( message, "expected false but was true" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to null.
		 */
		protected function assertNull(... rest):void
		{
			if ( rest.length == 2 )
				failNotNull( rest[0], rest[1] );
			else
				failNotNull( "", rest[0] );
		}
	
        /**
         * @private
         */
		protected function failNull( message:String, object:Object ):void
		{
			if ( object == null )
			   failWithUserMessage( message, "object was null: " + object );
		}
	
		/**
		 * Asserts that the provided argument does not evaluate to null.
		 */
		protected function assertNotNull(... rest):void
		{
			if ( rest.length == 2 )
				failNull( rest[0], rest[1] );
			else
				failNull( "", rest[0] );
		}
	
        /**
         * @private
         */
		protected function failNotNull( message:String, object:Object ):void
		{
			if ( object != null )
			   failWithUserMessage( message, "object was not null: " + object );
		}
	
		/**
		 * Immediately causes the test to fail with the message provided.
		 */
		protected function fail( failMessage:String = ""):void
		{
			throw new AssertionFailedError( failMessage );
		}
	

        /**
         * @private
         */
		private function failWithUserMessage( userMessage:String, failMessage:String ):void
		{
			if ( userMessage.length > 0 )
				userMessage = userMessage + " - ";
	
			throw new AssertionFailedError( userMessage + failMessage );
		}

		/**
		 * @private
		 */
		protected var _sorter:Sort;

		/** 
		 * Allows the developer to control the order that the methods are run by specifying a 
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
				if ( testCollection ) {
					testCollection.sort = sorter;
					testCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/**
		 * @private
		 */
		protected var _filter:Function = defaultFilterFunction;

		/** 
		 * Allows the developer to control which methods are executed by passing a filter function.
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
				if ( testCollection ) {
					testCollection.filterFunction = filter;
					testCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/** 
		 * A default implementation of the filterFunction which includes all methods beginning with 'test'. 
		 * The developer can provide their own fitler function or override this through inheritance. 
		 */
		protected function defaultFilterFunction( item:Object ):Boolean {
			if ( ( /^test.*/.test( item.@name ) ) ) {
				return true;
			}
			
			//Also check if it has a 'Test' metadata and include those items
			if ( item.hasOwnProperty( 'metadata' ) ) {
				var metaList:XMLList = item.metadata.(@name=='Test');
				
				if ( metaList.length() > 0 ) {
					return true;
				}
			}

			return false;
		}

		/** 
		 * A generic function that can be used with asynchronous code when we choose to wait until something occurs,
		 * but do not actually need to test anything when complete. This is often used to wait until asynchronous setup
		 * is complete before continuing.  
		 */
		protected function pendUntilComplete( event:Event, passThroughData:Object ):void {
		}

        /**
        * Constructor.
        */
		public function TestCase() {
			if (!sorter) {
				var sort:Sort = new Sort();
				sort.fields = [ new SortField( "@name" ) ];
				sorter = sort;
			}

			testCollection = buildTestCollection();
			testCollection.sort = sorter;
			testCollection.filterFunction = filter;
			testCollection.refresh();
			
			cursor = testCollection.createCursor();
		}
	}
}
