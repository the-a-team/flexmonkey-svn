/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.flexunit.tests
{	
    import com.gorillalogic.flexmonkey.application.events.MonkeyFileEvent;
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
    import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyCommandRunner;
    import com.gorillalogic.flexmonkey.monkeyCommands.SubtestResult;
    import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
    
    import flash.events.IEventDispatcher;
    
    import net.digitalprimates.fluint.tests.TestCase;

	public class MonkeyFlexUnitTestCase extends TestCase implements IEventDispatcher
	{ 
		public function MonkeyFlexUnitTestCase()
		{
			super();
            addEventListener(MonkeyFileEvent.LOAD_SNAPSHOT,loadSnapshotHandler,false,0,true);
		}
		
		public var context:MonkeyFlexUnitTestContext;   
		public var commandRunner:MonkeyCommandRunner = new MonkeyCommandRunner();
        	
        /**
         * Start running a MonkeyTest.
         * 
         * @param monkeyTest The MonkeyTest to be run
         * @param completeHandler The method called when the test run completes.  Normally this method will call <code>checkCommandResults.</code>
         * @param timeoutTime Time in ms the test is allowed to be run before timeout.
         * @param timeoutHandler The method called on timeout.
         */
        public function startTest(monkeyTest:MonkeyTest, completeHandler:Function, timeoutTime:int, timeoutHandler:Function):void {
        	// VerifyMonkeyCommands need a mateDispatcher to handle the snapshot load events
        	for each (var command:MonkeyRunnable in monkeyTest.children){
    			if ( command is VerifyMonkeyCommand ) {
    				VerifyMonkeyCommand(command).mateDispatcher = this;
    			}
        	}
        	commandRunner.addEventListener(MonkeyCommandRunnerEvent.COMPLETE, asyncHandler(completeHandler, timeoutTime, null, timeoutHandler));
            addEventListener(MonkeyCommandRunnerEvent.ERROR, commandErrorHandler);
            commandRunner.startPlaying(monkeyTest);
        }	
        
        /**
         * Report failure or error in a run MonkeyTest based on results stored in the MonkeyCommands.
         */
        public function checkCommandResults(monkeyTest:MonkeyTest):void{
            for each (var command:MonkeyRunnable in monkeyTest.children){
                if(command.error != null){
            	    throw new Error(command.shortDescription + ': ' + command.error);
                }
                if(command is VerifyMonkeyCommand){
                    var subtestResults:Array = VerifyMonkeyCommand(command).subtestResults;
                    for each ( var subtestResult:SubtestResult in subtestResults ) {
                        assertEquals(subtestResult.description, subtestResult.expectedValue, subtestResult.actualValue);
                    }
                }
            }
        }
        
		/**
		 * Load a snapshot as requested by a VerifyMonkeyCommand.
		 */
        public function loadSnapshotHandler(event:MonkeyFileEvent):void{
            context.snapshotLoader.getSnapshot(event.url,VerifyMonkeyCommand(event.data));
        }

		/**
		 * Handle error in MonkeyCommand.  This implementation does not report the error, as that will happen in the complete handler.
		 */
        public function commandErrorHandler(event:MonkeyCommandRunnerEvent):void{
            commandRunner.stopPlaying();
        }

		/**
		 * Handle test timeout.
		 */
        public function defaultTimeoutHandler(passThroughData:Object):void{
            commandRunner.stopPlaying();
            fail("Test timed out");
        }				
	}
}