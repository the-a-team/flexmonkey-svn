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
package net.digitalprimates.fluint.ui {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.controls.ToolTip;
	import mx.core.Container;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.managers.ToolTipManager;
	
	import net.digitalprimates.fluint.events.ChooseTestMethodResultEvent;
	import net.digitalprimates.fluint.monitor.TestCaseResult;
	import net.digitalprimates.fluint.monitor.TestMethodResult;
	import net.digitalprimates.fluint.monitor.TestSuiteResult;

	/** 
	 * The 'chooseTestMethodResult' event is fired when the user clicks on 
	 * the visual representation of a TestMethodResult in the progress bar.
	 * 
     * @eventType net.digitalprimates.fluint.events.ChooseTestMethodResultEvent.CHOOSE_TEST_METHOD_RESULT
	 **/
	[Event(name="chooseTestMethodResult",type="net.digitalprimates.fluint.events.ChooseTestMethodResultEvent")]

	/**
	 * A visual progress bar with discrete feedback for each test method executed. 
	 * 
	 * Test methods that fail are highlighted in red and can interact with the mouse. 
	 * Hovering over a method indicator will provide a tooltip with the method name. 
	 * Clicking on the indicator broadcasts an event with the TestMethodResult 
	 */
	public class TestProgressBar extends Container {
        /**
         * @private
         */
		private var _numberTestCases:int;
        /**
         * @private
         */
		private var _numberErrors:int;
        /**
         * @private
         */
		private var _numberFailures:int;

        /**
         * @private
         */
		protected var collection:ArrayCollection;

        /**
         * @private
         */
		private var numberTestCasesChanged:Boolean = false;
        /**
         * @private
         */
		private var numberErrorsChanged:Boolean = false;
        /**
         * @private
         */
		private var numberFailuresChanged:Boolean = false;
        /**
         * @private
         */
		private var dataProviderChanged:Boolean = false;

        /**
         * @private
         */
		protected var testsLabel:Label;
        /**
         * @private
         */
		protected var errorsLabel:Label;
        /**
         * @private
         */
		protected var failuresLabel:Label;

        /**
         * @private
         */
		protected var testCaseSize:int;
        /**
         * @private
         */
		protected var indexMap:Array = new Array();
        /**
         * @private
         */
		protected var hoverTimer:Timer;
        /**
         * @private
         */
		protected var displayTip:ToolTip;

		[Bindable('propertyChanged')]
		/**
		 * The number of test cases in the system. 
		 * 
		 * Used to determine the size occupied by an individual test 
		 * case in the progress bar.
		 */		
		public function get numberTestCases():int {
			return _numberTestCases;
		}

        /**
         * @private
         */
		public function set numberTestCases( value:int ):void {
			var propEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'numberTestCases', _numberTestCases, value ); 
			_numberTestCases = value;

			invalidateProperties();
			this.invalidateDisplayList();
			dispatchEvent( propEvent );
		}

		[Bindable('propertyChanged')]
		/**
		 * The number of tests that have failed during this testing process 
		 */
		public function get numberFailures():int {
			return _numberFailures;
		}

        /**
         * @private
         */
		public function set numberFailures( value:int ):void {
			var propEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'numberFailures', _numberFailures, value ); 
			_numberFailures = value;

			invalidateProperties();
			dispatchEvent( propEvent );
		}

		[Bindable('propertyChanged')]
		/**
		 * The number of tests that have thrown an error (not a failure) during 
		 * this testing process 
		 */
		public function get numberErrors():int {
			return _numberErrors;
		}

        /**
         * @private
         */
		public function set numberErrors( value:int ):void {
			var propEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'numberErrors', _numberErrors, value ); 
			_numberErrors = value;

			invalidateProperties();
			dispatchEvent( propEvent );
		}

		[Bindable('dataProviderChanged')]
		/**
		 * The dataProvider that feeds the progress bar. Generally, the 
		 * TestMonitor.testSuiteCollection.
		 */
		public function get dataProvider():ArrayCollection {
			return collection;
		}

        /**
         * @private
         */
		public function set dataProvider( value:ArrayCollection ):void {
			
			if ( collection ) {
				collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange );
			}

			collection = value;

			if ( collection ) {
				collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange, false, 0, true );
			}
			dataProviderChanged = true;
			invalidateProperties();
			dispatchEvent( new Event( 'dataProviderChanged' ) );
		}

        /**
         * @private
         */
		protected function handleCollectionChange( event:CollectionEvent ):void {
			if ( event.kind == CollectionEventKind.RESET ) {
				this.invalidateDisplayList();
			} else if ( event.kind == CollectionEventKind.UPDATE ) {
				//trace("Update value");
				this.invalidateDisplayList();
			}
		}
		
        /**
         * @private
         */
		override protected function commitProperties():void {
			super.commitProperties();
			
			if ( numberTestCasesChanged && testsLabel ) {
				numberTestCasesChanged = false;
				testsLabel.text = "Running " + numberTestCases + " Tests";
			}

			if ( numberErrorsChanged && errorsLabel ) {
				numberErrorsChanged = false;
				errorsLabel.text = numberErrors + " Errors";
			}

			if ( numberFailuresChanged && failuresLabel ) {
				numberFailuresChanged = false;
				failuresLabel.text = numberFailures + " Failues";
			}
			
			if ( dataProviderChanged ) {
				dataProviderChanged = false;
			}
		}

        /**
         * @private
         */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			testsLabel.setActualSize( testsLabel.getExplicitOrMeasuredWidth(), testsLabel.getExplicitOrMeasuredHeight() );
			errorsLabel.setActualSize( errorsLabel.getExplicitOrMeasuredWidth(), errorsLabel.getExplicitOrMeasuredHeight() );
			failuresLabel.setActualSize( failuresLabel.getExplicitOrMeasuredWidth(), failuresLabel.getExplicitOrMeasuredHeight() );

			testsLabel.move( 0, 0 );
			failuresLabel.move( unscaledWidth-failuresLabel.width, 0 );
			errorsLabel.move( ( failuresLabel.x - errorsLabel.width ) - 5, 0 );
			
			//Cap this so we never take less than 6 pixels per test..scroll if needed
			testCaseSize = Math.max( ( unscaledWidth/numberTestCases ), 6 );
			
			rebuildProgressBar();
		}

        /**
         * @private
         */
		override protected function createChildren():void {

			if ( !testsLabel ) {
				testsLabel = new Label()
				addChild( testsLabel );
			}

			if ( !errorsLabel ) {
				errorsLabel = new Label()
				addChild( errorsLabel );
			}

			if ( !failuresLabel ) {
				failuresLabel = new Label()
				addChild( failuresLabel );
			}

			super.createChildren();			
		}

        /**
         * @private
         */
		protected function rebuildProgressBar( updateIndex:int=-1 ):void {
			var positionCounter:int = 0;

			indexMap = new Array();
			graphics.clear();
			graphics.lineStyle( 1, 0x000000, 1 );
			var xPos:int = 0;
			//Draw each testcase
			var testSuiteResult:TestSuiteResult;
			var testCaseResult:TestCaseResult;
			var testMethodResult:TestMethodResult;
			for ( var i:int=0; i<collection.length; i++ ) {
				testSuiteResult = collection.getItemAt( i ) as TestSuiteResult;
				for ( var j:int=0; j<testSuiteResult.children.length; j++ ) {
					testCaseResult = testSuiteResult.children[ j ] as TestCaseResult;
					if ( testCaseResult ) {
						indexMap.push( { position:positionCounter, children:testCaseResult.children } );
					}

					for ( var k:int=0; k<testCaseResult.children.length; k++ ) {
						testMethodResult = testCaseResult.children[ k ] as TestMethodResult;

						if ( testMethodResult.executed ) {
							if ( testMethodResult.status ) {
								graphics.beginFill( 0x00FF00, 1 );
							} else {
								graphics.beginFill( 0xFF0000, 1 );
							}
							graphics.drawRect( xPos, 0, testCaseSize, 28  );
							graphics.endFill();
						}
						xPos += testCaseSize;
						positionCounter++;
					}					
				}			
			}			
			
		}
		
        /**
         * @private
         */
		protected function getMethodResult( point:Point ):TestMethodResult {
			var testNumber:int = point.x/testCaseSize;
			var location:int = -1;
			var arrayIndex:int;
			var tmr:TestMethodResult;

			var found:Boolean = false;
			for ( var i:int=0; i<indexMap.length; i++ ) {
				if ( indexMap[ i ].position > testNumber ) {
					location = i-1;
					found = true;
					break;
				}
			}
			
			if ( !found ) {
				location = indexMap.length - 1;
			}

			if ( location >= 0 ) {
				arrayIndex = testNumber - indexMap[ location ].position;
				if ( ( location < indexMap.length ) && ( arrayIndex < indexMap[ location ].children.length ) ) {
					tmr =  ( indexMap[ location ].children[ arrayIndex ] ) as TestMethodResult;
				}
			}
			
			return tmr;
		}	
	
        /**
         * @private
         */
		protected function createFunctionTip():void {
			var point:Point = this.localToGlobal( new Point( mouseX-10, 30 ) );
			if ( !displayTip ) {
				displayTip = ToolTipManager.createToolTip( 'Yo', point.x, point.y, 'errorTipBelow' ) as ToolTip;
			}

			var testMethodResult:TestMethodResult = getMethodResult( point );
			
			if ( testMethodResult && !testMethodResult.status ) {
				displayTip.move( point.x, point.y );
				displayTip.text = testMethodResult.toString();;
				displayTip.visible = true;
			} else {
				displayTip.visible = false;			
			}
		}

        /**
         * @private
         */
		protected function handleHover( event:TimerEvent ):void {
			createFunctionTip();
			hoverTimer.stop();			
		}

        /**
         * @private
         */
		protected function handleMouseMove( event:MouseEvent ):void {
			if ( displayTip ) {
				displayTip.visible = false;
			}	

			hoverTimer.reset();
			hoverTimer.start();
		}
		
        /**
         * @private
         */
		protected function handleRollout ( event:MouseEvent ):void {
			if ( displayTip ) {
				ToolTipManager.destroyToolTip( displayTip );
				displayTip = null;
			}	
		}

        /**
         * @private
         */
		protected function handleClick ( event:MouseEvent ):void {
			event.stopImmediatePropagation();

			var testMethodResult:TestMethodResult = getMethodResult( new Point( event.localX, event.localY ) );

			if ( testMethodResult ) {
				dispatchEvent( new ChooseTestMethodResultEvent( ChooseTestMethodResultEvent.CHOOSE_TEST_METHOD_RESULT, false, false, testMethodResult ) );
			}
		}

        /**
        * Constructor.
        */
		public function TestProgressBar() {
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove );
			addEventListener(MouseEvent.ROLL_OUT, handleRollout );
			addEventListener(MouseEvent.CLICK, handleClick );
			hoverTimer = new Timer( 500, 1 );
			hoverTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleHover );
		}
	}
}