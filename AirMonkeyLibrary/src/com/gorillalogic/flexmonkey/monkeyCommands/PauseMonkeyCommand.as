/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	
	import flash.utils.Timer;	
	[Bindable]
	public class PauseMonkeyCommand extends MonkeyRunnable
	{	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
			
		public function PauseMonkeyCommand(duration:uint=0)
		{
			this.duration = duration;			
		}
		
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));
			timer.delay = duration;
			timer.start();
			hasBeenRun = true;
			return true;
		}		

		override public function get xml():XML{
			var xml:XML = 
			<Pause duration={duration}/>			
			return xml;		
		}
		
		public function getAS3(testName:String):String{
			return "new PauseMonkeyCommand(" + duration + ")";
		}	
			
		override public function get thinkTime():uint {
			return duration;
		}
		
		private var _duration:uint;
		public function get duration():uint{
			return _duration;
		}
		public function set duration(d:uint):void{
			_duration = d; 
		}
		
		override public function isEqualTo(item:Object):Boolean{
			if(! item is PauseMonkeyCommand){
				return false;
			}else{
				if(item.duration == this.duration){
					return true;
				}else{
					return false;
				}
			}
		}
		
		public function clone():PauseMonkeyCommand{
			var copy:PauseMonkeyCommand = new PauseMonkeyCommand();
			copy.mateDispatcher = mateDispatcher;
			copy.parent = this.parent;
			copy.duration = this.duration;			
			return copy;
		}			
	}
}