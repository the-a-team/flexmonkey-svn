/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2.  
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	import com.gorillalogic.flexmonkey.core.*;
	
	import flash.utils.Timer;	
	[Bindable]
	public class CallMonkeyCommand extends MonkeyRunnable
	{	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
			
		public var func:Function;	
			
		public function CallMonkeyCommand(func:Function=null)
		{
			this.func = func;			
		}
		
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));
			func();
			timer.start();
			hasBeenRun = true;
			return true;
		}		

		override public function get xml():XML{
			var xml:XML = 
			<Call/>			
			return xml;		
		}
		
		public function getAS3(testName:String):String{
			return "new CallMonkeyCommand(" + func + ")";
		}	
			
		override public function get thinkTime():uint {
			return MonkeyTest(parent).defaultThinkTime;
		}
				
		override public function isEqualTo(item:Object):Boolean{
			if(! item is CallMonkeyCommand){
				return false;
			}else{
				if(item.func == this.func){
					return true;
				}else{
					return false;
				}
			}
		}
		
		public function clone():CallMonkeyCommand{
			var copy:CallMonkeyCommand = new CallMonkeyCommand();
			copy.mateDispatcher = mateDispatcher;
			copy.parent = this.parent;
			copy.func = this.func;			
			return copy;
		}			
	}
}