/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	
	public class MonkeyRunnerEngine extends EventDispatcher
	{
		private var cmds:ArrayCollection;
		private var currentCommandIndex:int;
		private var currentCommand:MonkeyRunnable;
		private var runTimer:Timer;
		private var timeoutTimer:Timer;
		private var commandRunner:MonkeyCommandRunner;
		
		public function MonkeyRunnerEngine()
		{	
		}
		
		public function runCommands(cmds:ArrayCollection, runner:MonkeyCommandRunner):void {	
			this.cmds = cmds;
			var timeoutTime:uint = 1000;
			if(cmds.length>0 && cmds[0].parent is MonkeyTest){
				timeoutTime = MonkeyTest(cmds[0].parent).timeoutTime + 1;
			}
			timeoutTimer = new Timer(timeoutTime + 1,1);
			timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,testTimeoutHandler,false,0,true);
//			timeoutTimer.start();
			this.commandRunner = runner;
			this.currentCommandIndex = 0;
			runTimer = new Timer(1, 1);				
			runTimer.addEventListener(TimerEvent.TIMER_COMPLETE, runCommand);
			runTimer.start();
		}

		private function testTimeoutHandler(event:TimerEvent):void{
			// TODO Set error on command?
//Alert.show("Test Timeout");			
			testComplete();
		}


		public function runCommand(event:TimerEvent=null):void{
			if(currentCommandIndex==cmds.length){
				testComplete();
				return;
			}else if(commandRunner.isPaused){
				runTimer.delay = 100;	
				runTimer.start();
				return;
			}else if(!commandRunner.isPlaying){
				testComplete();
				return;
			}
			currentCommand = cmds[currentCommandIndex];

			runTimer.delay = currentCommand.thinkTime; // timer is stopped when this new delay is set so it does not restart

			if(commandRunner.browserConnection != null && commandRunner.browserConnection.useBrowser){
				if(currentCommand is UIEventMonkeyCommand){
//Alert.show("Run " + UIEventMonkeyCommand(currentCommand).command + " " + UIEventMonkeyCommand(currentCommand).value);					
					UIEventMonkeyCommand(currentCommand).execute0(commandRunner,runTimer);
					commandRunner.browserConnection.runCommand(UIEventMonkeyCommand(currentCommand),this);
					return;
				}
			}
			currentCommand.execute(commandRunner,runTimer);
			finishRun();
		}	
		
		public function agentRunDone(evilTwin:MonkeyRunnable):void{
			currentCommand.assimilateEvilTwin(evilTwin);
			if(currentCommand is UIEventMonkeyCommand){
//Alert.show("AgentRunDone " + UIEventMonkeyCommand(currentCommand).command + " " + UIEventMonkeyCommand(currentCommand).value);									
				UIEventMonkeyCommand(currentCommand).execute2(commandRunner,runTimer);
			}
			finishRun();
		}
		
		public function finishRun():void{
			if(currentCommand is UIEventMonkeyCommand && currentCommand.error != null){
				testComplete();
			}else{
				currentCommandIndex++;
			}			
		}
		
		private function testComplete():void{
			runTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, runCommand);
			timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, testTimeoutHandler);
			dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE,currentCommand));			
		}
		
					
	}
}