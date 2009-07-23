/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.flexmonkey.application.events.AlertEvent;
	import com.gorillalogic.flexmonkey.application.managers.BrowserConnectionManager2;
	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;	



	/**
	 *  Dispatched when the MonkeyCommandRunner tries to playback a command.
	 *
	 *
	 *  @eventType com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent.EXECUTE
	 */	
	[Event(name="execute", type="com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent")]


	/**
	 *  Dispatched when the MonkeyCommandRunner completes playback.
	 *
	 *
	 *  @eventType com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent.COMPLETE
	 */	
	[Event(name="complete", type="com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent")]

	
	/**
	 * The MonkeyCommandRunner runs a hierarchical collection of MonkeyCommands.
	 * 
	 * 
	 */
	public class MonkeyCommandRunner extends EventDispatcher
	{
		/**
		 * The event mateDispatcher used by MonkeyCommandRunner.
		 * 
		 * @default this
		 */	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);


		public var browserConnection:BrowserConnectionManager2;


		private var _isPlaying:Boolean = false;
		/**
		 * Indicates that the MonkeyCommandRunner is currently playing back commands.
		 * 
		 * 
		 */
		[Bindable ("isPlayingChanged")]
		public function get isPlaying():Boolean{
			return _isPlaying;
		}		

		private var _isPaused:Boolean = false;
		/**
		 * Indicates that the MonkeyCommandRunner is currently playing back commands, but is in the paused state.
		 * 
		 * 
		 */
		[Bindable ("isPausedChanged")]
		public function get isPaused():Boolean{
			return _isPaused;
		}

//		public var thinkTime:int = 500;

		public var selectedItem:MonkeyRunnable;
		
		public var useBrowser:Boolean = false;

		/**
		 * Constructor.
		 * 
		 * 
		 */
		public function MonkeyCommandRunner()
		{
		}

		/**
		 * Initiates playback of a hierarchical collection of MonkeyCommands.
		 * 
		 * @param startCommand Playback begins at the startCommand.  
		 * 
		 * 
		 */
		public function startPlaying(startCommand:MonkeyRunnable = null):void{
			if(startCommand == null ){			
				startCommand = this.selectedItem;
			}	
			if(!(startCommand is MonkeyNode)){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", 
						"FlexMonkey does not currently support running single commands!", 
						"Please select a TestSuite, TestCase, or Test."));
				_isPlaying = false;
				dispatchEvent(new Event("isPlayingChanged"));				
				return;
			}		
			if(!_isPlaying){
				_isPlaying = true;
				dispatchEvent(new Event("isPlayingChanged"));	
				this.startCommand = startCommand;									
				startCommand.addEventListener(MonkeyCommandRunnerEvent.COMPLETE,playingCompleteHandler,false,0,true);
				startCommand.resetResult();	
				startCommand.updateParentResult();
				startCommand.execute(this);	
	 		}				
		}
		private var startCommand:MonkeyRunnable;
		private function playingCompleteHandler(event:MonkeyCommandRunnerEvent):void{
			startCommand.removeEventListener(MonkeyCommandRunnerEvent.COMPLETE,playingCompleteHandler);
			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE,startCommand));			
			_isPlaying = false;
			dispatchEvent(new Event("isPlayingChanged"));						
		}		
				
		/**
		 * If the MonkeyCommandRunner is currently playing, this method stops playback.
		 * 
		 * 
		 */
		public function stopPlaying():void{
			if(_isPlaying){
				_isPlaying = false;
				dispatchEvent(new Event("isPlayingChanged"));
			}				
		}

		/**
		 * If the MonkeyCommandRunner is playing, this method pauses the player.
		 * 
		 * 
		 */		
		public function startPausing():void{
			if(_isPlaying && !_isPaused){
				_isPaused = true;
				dispatchEvent(new Event("isPausingChanged"));
			}	
		}

		/**
		 * If the MonkeyCommandRunner is paused, this method resumes playing.
		 * 
		 * 
		 */			
		public function stopPausing():void{
			if(_isPaused){
				_isPaused = false;
				dispatchEvent(new Event("isPausingChanged"));				
			}
		}


				
	}	
}